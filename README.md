# Standalone On-Premises Collaboration Server Kickstart

This repository contains a Kickstart file for setting up a **standalone, on-premises collaboration server** that mimics the core features of Microsoft Exchange, such as email communication, calendar management, task tracking, and file sharing. The server operates **entirely offline** on a **local LAN** and is designed for use in environments where connectivity to an off-premises Exchange server is **Denied, Degraded, Interrupted, or Lost (DDIL)**. When internet connectivity is restored, the system can synchronize data with an external Exchange server.

---

## Features

- **Email Communication**: Local SMTP and IMAP/POP3 services using Postfix and Dovecot.
- **Webmail Client**: Roundcube for managing emails through a web browser on the intranet.
- **Calendaring**: CalDAV support via Radicale for shared calendar management.
- **Task Management**: Tasks handled by Nextcloud.
- **File Sharing**: Local file sharing via Nextcloud, including role-based access control.
- **Contact Management**: CardDAV support via Radicale for local contact management.
- **Mobile Device Sync**: CalDAV and CardDAV syncing for mobile devices over the local network.
- **High Availability**: Keepalived provides high availability for critical services.
- **Security**: Integrated with OpenSSL, SpamAssassin, and ClamAV for secure communication and virus protection.
- **Backup**: Local backups handled via rsnapshot.
- **Offline Operation**: Fully functional in a **disconnected** or **DDIL** environment.
- **Sync with Exchange**: Capable of synchronizing with an external Exchange server when connectivity is restored.

---


---

## Usage

### 1. Installation
This Kickstart file automates the installation of a full collaboration server. To use this file:
1. Create a bootable ISO or USB stick with the Kickstart configuration.
2. Boot the target system with the media and allow the automated installation to complete.
3. The system will reboot and the collaboration server will be ready to use within the local network.

### 2. Key Services
After installation, the following services will be running on the local network:
- **Postfix (SMTP)**: Handles sending and receiving emails.
- **Dovecot (IMAP/POP3)**: Manages email retrieval for users.
- **Roundcube (Webmail)**: Provides a web interface for email management.
- **Radicale (CalDAV/CardDAV)**: Manages calendars and contacts.
- **Nextcloud (File Sharing/Task Management)**: Provides file sharing and task management.

You can access the services locally by navigating to `http://collabserver.local` from any machine on the local network.

---

## Why Use This Server?

### Denied, Degraded, Interrupted, or Lost (DDIL) Networks

This collaboration server is designed to function in **DDIL** network environments. **DDIL** refers to scenarios where internet connectivity is not reliable, or is outright unavailable. This can occur in situations such as:
- **Remote Locations**: Places where continuous internet access is not feasible.
- **Military/Defense Operations**: Field operations where communication infrastructure is disconnected.
- **Disaster Recovery**: During natural disasters or emergencies where the internet is inaccessible.

In such scenarios, typical cloud-based solutions like Microsoft Exchange become impractical. Instead, a **local edge server** that operates **entirely on-premises** within the LAN is crucial. This server:
- Provides **uninterrupted email, file, and calendar services** even when connectivity to the internet is lost.
- Ensures that local collaboration can continue without the need for external servers.
- Once connectivity is restored, it **syncs** back to the Exchange server, ensuring that no data is lost and all updates are applied.

### Key Benefits in DDIL Environments:
1. **Offline Functionality**: Full email, calendar, and file services within a closed local network.
2. **Resilience**: Can withstand internet outages without losing any core functionality.
3. **Sync Capability**: Automatically syncs with an external Exchange server once connectivity is restored.
4. **Data Sovereignty**: All data is stored locally on the server, minimizing reliance on external systems.

---

## Future Work
In future versions, additional features such as more robust sync logic with Microsoft Exchange and extended mobile device support can be added.

Feel free to contribute or report any issues in the GitHub repository.

---

## Directory Structure

The following file and directory structure is created by the Kickstart file during installation. This structure ensures proper organization and separation of services for the collaboration server.

Key Components of the Structure:

    /boot/: Contains the bootloader and kernel files for the system.
    /home/: User-specific directories, where each user's local files and data will be stored.
    /var/lib/radicale/collections/: Radicale’s data storage for CalDAV (calendar) and CardDAV (contacts) data.
    /var/mail/domain/: Email storage location using Maildir format, where emails are kept for each domain and user.
    /var/backups/rsnapshot/: Backup directory for rsnapshot where system backups will be stored.
    /var/www/html/nextcloud/: Nextcloud’s root directory for both configuration and user data.
    /etc/postfix/: Configuration files for Postfix (local SMTP server).
    /etc/dovecot/: Configuration files for Dovecot (IMAP/POP3 server).
    /etc/nginx/conf.d/: Configuration files for Nginx web server (handling Roundcube webmail).
    /etc/roundcubemail/: Configuration directory for Roundcube, where its settings are managed.
    /etc/radicale/: Configuration files for Radicale (CalDAV/CardDAV services).
    /etc/rsnapshot.conf: Main configuration file for managing backup jobs with rsnapshot.
    /etc/clamav/ and /etc/spamassassin/: Directories containing configurations for virus scanning (ClamAV) and spam filtering (SpamAssassin).
    /etc/keepalived/: Configuration files for Keepalived, providing high availability for services.

This structure ensures that all services, from email to file sharing and backups, are properly organized and configured for offline collaboration, with the ability to sync to Microsoft Exchange once the internet connection is restored.

dentity Synchronization from Local Server to Microsoft Exchange

Currently, the setup described for the standalone collaboration server is designed to function offline and provide local collaboration services (e.g., email, calendaring, file sharing) over a LAN. The challenge lies in synchronizing identities (e.g., name@fqdn) from the local system to a real Exchange server when connectivity is restored, given that identity management across multiple environments like this isn't handled natively by the Kickstart solution.

Let me walk through both the current limitations and a potential future solution for synchronizing identity information (like email addresses) from the local system to a Microsoft Exchange server.
Current State: Identity Handling

In this offline setup, the local system manages identities for users within the confines of the LAN, including:

    Email addresses: user@collabserver.local
    Local mailboxes
    Calendars (CalDAV via Radicale)
    Contacts (CardDAV via Radicale)
    Tasks and files (via Nextcloud)

Current Setup:

    Local Email (Postfix/Dovecot): Postfix handles email delivery locally using email addresses like name@collabserver.local. These addresses are specific to the local domain and managed entirely on-premises.
    Local User Accounts: Each user is manually created and managed via the Postfix and Dovecot configuration.
    No Active Directory Integration: In this setup, there is no integration with a central identity provider like Microsoft Active Directory (AD), which would handle user identities across both the local system and the Exchange server.

Issue: Because there is no identity federation or synchronization mechanism between the local system and the external Exchange server, users would have distinct email identities locally and on Exchange. For example, user@collabserver.local could exist locally, but there is no automatic synchronization to user@company.com (the Exchange identity) when connectivity is restored.
Possible Future Solution: Identity Synchronization

To support synchronization of identities like name@fqdn (e.g., name@company.com) from this local server to a real Exchange server, future iterations of this system would need to incorporate directory synchronization and user identity federation. Here’s how that could potentially work:
1. Integrating Microsoft Active Directory (AD) or LDAP

    Active Directory (AD) or LDAP could be used on-premises to manage user identities centrally.
    Active Directory Lightweight Directory Services (AD LDS) could be deployed on the local server as a lightweight version of AD, which can run offline and handle local user identities.
    LDAP (Lightweight Directory Access Protocol): Alternatively, an LDAP server could be used to manage users and groups locally.

How it Works:

    Users would authenticate against the local AD/LDAP server, and their identities would be consistent both locally and when connected to the Exchange environment.
    Once internet connectivity is restored, Azure AD Connect or AD FS (Active Directory Federation Services) could sync the identities and attributes (e.g., email addresses) from the local AD/LDAP to the Exchange server.
    This would allow the identities used offline (e.g., name@collabserver.local) to synchronize with the identities on Exchange (e.g., name@company.com), ensuring a consistent user identity across both environments.

Benefits:

    Unified Identity: Users would only need to manage one identity, whether offline or connected.
    Seamless Synchronization: Once connectivity is restored, user information (like email addresses, group memberships, etc.) is synced to the Exchange environment.

2. Using Azure AD Connect for Hybrid Identity

    Azure AD Connect is Microsoft's tool for synchronizing on-premises identities (from Active Directory or LDAP) to Azure AD.
    In the future, this system could deploy Azure AD Connect to handle synchronization between the local server’s identities and the cloud-based Microsoft Exchange.

How it Works:

    Azure AD Connect would ensure that the local directory (on the collaboration server) synchronizes with Azure AD, which is in turn linked to the Exchange server.
    Users’ local email addresses (e.g., user@collabserver.local) could be mapped and synced to their Exchange identities (e.g., user@company.com).

Benefits:

    Hybrid Identity Management: This allows for offline identity management with synchronization to the cloud or Exchange environment when internet connectivity returns.
    Password Sync: Passwords and credentials could also be synced, ensuring a seamless login experience across both local and cloud systems.

3. IMAP/SMTP Sync with Microsoft Exchange

    A lightweight solution could involve using IMAP sync to synchronize mailboxes from the local system to the Exchange server.
    Once connectivity is restored, an IMAP sync tool could push emails from the local Dovecot server to Exchange using IMAP migration.

Challenges:

    This solution only syncs emails, not user identities. Users would still have separate local identities.
    It's less efficient than directory synchronization because it doesn't unify the identity across systems (e.g., name@collabserver.local vs. name@company.com).

4. Mapping Local Identities to Exchange Identities

    In future iterations, a mapping layer could be built into the system where local email addresses (e.g., user@collabserver.local) are mapped to external Exchange identities (e.g., user@company.com).
    A custom synchronization daemon could be developed to ensure that local changes to email addresses or identities are reflected on the Exchange server and vice versa.

Challenges:

    Requires careful handling of identity mapping rules and conflict resolution when email addresses differ between environments.
    There would still be a need for a centralized identity store (like AD or LDAP) to manage this mapping efficiently.

Key Considerations for Future Iterations:

    Centralized Identity Management: Implementing a centralized identity management system such as Active Directory or LDAP would allow seamless synchronization of user identities across offline and online environments.

    Federation with Azure AD: Enabling hybrid identity management by federating local AD/LDAP with Azure AD ensures that user identities are consistently managed in both the local environment and cloud services (like Exchange).

    Synchronization of Mailboxes: In future iterations, IMAP sync tools could handle email synchronization, ensuring that local mailbox content syncs to Exchange.

    Identity and Access Management (IAM) Tools: The use of IAM solutions to integrate and manage identities across multiple systems could help ensure a smooth user experience across local and cloud systems.

Summary:

Currently, this system doesn't support synchronizing local identities (e.g., name@collabserver.local) to an external Exchange environment because there is no centralized identity management solution in place. In future versions, incorporating Active Directory or LDAP on the local server, coupled with tools like Azure AD Connect, would allow for identity synchronization between the local offline environment and the external Exchange server once connectivity is restored. This would provide a unified, seamless experience for users, ensuring that their identities, emails, and other information are consistent across systems.

—

## How It Works

### 1. **FreeIPA Setup**
   - FreeIPA is installed as the **Identity Provider (IdP)**, handling user identities, authentication, and authorization.
   - Users are created and managed centrally using FreeIPA’s tools. These users can log into any local service that integrates with FreeIPA (e.g., Nextcloud, Postfix).

### 2. **SAML Federation with Apache mod_auth_mellon**
   - The system uses **SAML** for identity federation. SAML allows users to authenticate to different services using a single identity managed by FreeIPA.
   - **mod_auth_mellon** is a module for Apache HTTP Server that enables **SAML authentication**. It is configured to work with FreeIPA as the IdP.
   - Local services like **Nextcloud** or **Roundcube** will authenticate users via SAML, providing **Single Sign-On (SSO)**.

### 3. **Postfix and Dovecot Email Services**
   - **Postfix** is deployed as the local SMTP server, while **Dovecot** handles IMAP/POP3 for local mailboxes.
   - Both Postfix and Dovecot are configured to authenticate users via FreeIPA, ensuring that all email accounts are centrally managed.

### 4. **Nextcloud File Sharing**
   - **Nextcloud** is configured as a local file-sharing platform. It integrates with FreeIPA for user authentication, meaning users can log into Nextcloud using the same credentials they use for email or other services.

### 5. **Identity Federation for External Services**
   - In future iterations, **FreeIPA** can be extended to synchronize with external identity providers like **Azure AD** or **Microsoft Exchange** using tools like **Azure AD Connect** or **SAML** federation.
   - This setup allows users to have a consistent identity both on-premises and in the cloud. When internet connectivity is restored, local identities can be synced with external systems, providing seamless access to cloud services.

—

## Why Use Identity Federation?

### Benefits of Identity Federation in This Setup:
1. **Single Sign-On (SSO)**: Users can authenticate to multiple services using a single set of credentials, improving user experience and reducing password fatigue.
2. **Centralized Identity Management**: All user identities are managed centrally via FreeIPA, simplifying user management and enhancing security.
3. **Seamless Integration with Cloud Services**: By federating identities via SAML and FreeIPA, users can have a unified identity for both local and cloud services.
4. **Security**: Centralized authentication via FreeIPA ensures that access control policies are applied consistently across all services.

—

## Use Cases

This identity federation setup is ideal for environments where:

- **On-Premises Collaboration**: Organizations require full functionality for email, calendaring, and file sharing without relying on internet access.
- **DDIL Networks**: This solution is perfect for Denied, Degraded, Interrupted, or Lost (DDIL) networks, such as military deployments, remote locations, or disaster recovery scenarios.
- **Future Cloud Synchronization**: The system can be extended to synchronize with cloud services like Azure AD or Exchange, making it suitable for hybrid environments.

—

## Installation Instructions

1. **Create a bootable ISO or USB with this Kickstart file**.
2. **Boot the target system** using the bootable media and follow the automated installation process.
3. **Once installation completes**, the system will be set up with FreeIPA, SAML, Postfix, Dovecot, and Nextcloud.

—

## Future Enhancements

- **Azure AD Integration**: Future versions could integrate **Azure AD Connect** to synchronize FreeIPA identities with Azure AD, allowing seamless identity management across cloud services.
- **Expanded SAML Capabilities**: Additional local services can be configured to use SAML for authentication, further extending the Single Sign-On (SSO) capabilities of the system.

—

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
