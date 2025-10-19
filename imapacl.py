#!/usr/bin/env python3
import imaplib
import argparse
import getpass
import logging

def setup_logging(level):
    """Konfiguriert das Logging mit dem angegebenen Log-Level."""
    logging.basicConfig(
        level=level,
        format='%(asctime)s - %(levelname)s - %(message)s',
        handlers=[logging.StreamHandler()]
    )
    return logging.getLogger(__name__)

def connect_to_imap(server, port, username, password, logger):
    """Stellt eine Verbindung zum IMAP-Server her."""
    try:
        imap = imaplib.IMAP4_SSL(server, port)
        imap.login(username, password)
        logger.info("Erfolgreich mit dem IMAP-Server verbunden.")
        return imap
    except Exception as e:
        logger.error(f"Fehler bei der Verbindung: {e}")
        return None

def set_acl(imap, mailbox, user, acl, logger):
    """Setzt die ACL für einen Benutzer auf einem Postfach."""
    try:
        imap.setacl(mailbox, user, acl)
        logger.info(f"ACL für {user} auf {mailbox} erfolgreich gesetzt: {acl}")
    except Exception as e:
        logger.error(f"Fehler beim Setzen der ACL: {e}")

def delete_acl(imap, mailbox, user, logger):
    """Löscht die ACL für einen Benutzer auf einem Postfach."""
    try:
        imap.deleteacl(mailbox, user)
        logger.info(f"ACL für {user} auf {mailbox} erfolgreich gelöscht.")
    except Exception as e:
        logger.error(f"Fehler beim Löschen der ACL: {e}")

def list_acl(imap, mailbox, logger):
    """Listet die ACLs für ein Postfach auf."""
    try:
        acls = imap.getacl(mailbox)
        logger.info(f"ACLs für {mailbox}:")
        for acl in acls[1]:
            logger.info(f"  {acl.decode('utf-8')}")
    except Exception as e:
        logger.error(f"Fehler beim Auflisten der ACLs: {e}")

def main():
    parser = argparse.ArgumentParser(description="IMAP ACL Manager")
    parser.add_argument("--server", required=True, help="IMAP Server Adresse")
    parser.add_argument("--port", type=int, default=993, help="IMAP Port (Standard: 993)")
    parser.add_argument("--username", required=True, help="IMAP Benutzername")
    parser.add_argument("--mailbox", required=True, help="Postfach, für das die ACL geändert werden soll")
    parser.add_argument("--action", choices=["set", "delete", "list"], required=True, help="Aktion: set, delete oder list")
    parser.add_argument("--user", help="Benutzer, für den die ACL geändert werden soll (nur bei set/delete)")
    parser.add_argument("--acl", help="ACL-Rechte (nur bei set, z.B. 'lrswipkxteda')")
    parser.add_argument("--log-level", default="INFO", choices=["DEBUG", "INFO", "WARNING", "ERROR", "CRITICAL"], help="Log-Level (Standard: INFO)")

    args = parser.parse_args()
    logger = setup_logging(args.log_level)
    password = getpass.getpass("IMAP Passwort: ")

    imap = connect_to_imap(args.server, args.port, args.username, password, logger)
    if not imap:
        return

    try:
        if args.action == "set":
            if not args.user or not args.acl:
                logger.error("Für 'set' müssen --user und --acl angegeben werden.")
                return
            set_acl(imap, args.mailbox, args.user, args.acl, logger)
        elif args.action == "delete":
            if not args.user:
                logger.error("Für 'delete' muss --user angegeben werden.")
                return
            delete_acl(imap, args.mailbox, args.user, logger)
        elif args.action == "list":
            list_acl(imap, args.mailbox, logger)
    finally:
        imap.logout()
        logger.info("Verbindung zum IMAP-Server geschlossen.")

if __name__ == "__main__":
    main()
