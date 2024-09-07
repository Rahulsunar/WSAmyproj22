import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:women_safety_app/utils/constants.dart';

class ContactsPage extends StatefulWidget {
  const ContactsPage({super.key});

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  List<Contact> contacts = [];
  @override
  void initState() {
    super.initState();
    askPermissions(); // Optionally check permissions at init
  }

  Future<void> askPermissions() async {
    PermissionStatus permissionStatus = await getContactsPermissions();
    if (permissionStatus == PermissionStatus.granted) {
      getAllContacts();
    } else {
      handleInvalidPermissions(permissionStatus);
    }
  }

  void handleInvalidPermissions(PermissionStatus permissionStatus) {
    if (permissionStatus == PermissionStatus.denied) {
      dialougeBox(context, "Access to the contacts denied by the user");
    } else if (permissionStatus == PermissionStatus.permanentlyDenied) {
      dialougeBox(context, "Maybe Contacts doesn't exist on this device");
    }
  }

  getAllContacts() async {
    List<Contact> _contacts = await ContactsService.getContacts();
    setState(() {
      contacts = _contacts;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: contacts.length == 0
            ? Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: contacts.length,
                itemBuilder: (BuildContext context, int index) {
                  Contact contact = contacts[index];
                  return ListTile(
                    title: Text(contact.displayName ?? 'Unknown Number'),
                    subtitle: Text(contact.phones!.isNotEmpty
                        ? contact.phones!.elementAt(0).value!
                        : 'No phone number'),
                    leading:
                        contact.avatar != null && contact.avatar!.length > 0
                            ? CircleAvatar(
                                backgroundColor: primaryColor,
                                backgroundImage: MemoryImage(contact.avatar!),
                              )
                            : CircleAvatar(
                                backgroundColor: primaryColor,
                                child: Text(contact.initials()),
                              ),
                  );
                }));
  }
}

Future<PermissionStatus> getContactsPermissions() async {
  PermissionStatus permission = await Permission.contacts.status;
  if (permission != PermissionStatus.granted &&
      permission != PermissionStatus.permanentlyDenied) {
    PermissionStatus permissionStatus = await Permission.contacts.request();
    return permissionStatus;
  } else {
    return permission;
  }
}
