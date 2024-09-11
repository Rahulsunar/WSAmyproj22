import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:women_safety_app/db/db_services.dart';
import 'package:women_safety_app/model/contactsm.dart';
import 'package:women_safety_app/utils/constants.dart';

class ContactsPage extends StatefulWidget {
  const ContactsPage({super.key});

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  List<Contact> contacts = [];
  List<Contact> contactsFiltered = [];
  DatabaseHelper _databaseHelper = DatabaseHelper();
  TextEditingController searchController = TextEditingController();
  bool loading = true; // Flag to indicate loading state

  @override
  void initState() {
    super.initState();
    askPermissions();

    // Add listener to searchController to update the contact list as the user types
    searchController.addListener(() {
      filterContact();
    });
  }

  @override
  void dispose() {
    searchController.dispose(); // Dispose controller to prevent memory leaks
    super.dispose();
  }

  String flatternPhoneNumber(String phoneStr) {
    return phoneStr.replaceAllMapped(RegExp(r'(\+)|\D'), (Match m) {
      return m[0] == "+" ? "+" : "";
    });
  }

  filterContact() {
    List<Contact> _contacts = [];
    _contacts.addAll(contacts);

    if (searchController.text.isNotEmpty) {
      String searchTerm = searchController.text.toLowerCase();
      String searchTermFlattern = flatternPhoneNumber(searchTerm);

      _contacts.retainWhere((contact) {
        String contactName = contact.displayName?.toLowerCase() ?? '';
        bool nameMatches = contactName.contains(searchTerm);

        if (nameMatches) {
          return true;
        }
        if (searchTermFlattern.isEmpty) {
          return false;
        }

        // Search for phone number match
        var phone = contact.phones!.firstWhere((p) {
          String phnFlatterned = flatternPhoneNumber(p.value!);
          return phnFlatterned.contains(searchTermFlattern);
        },
            orElse: () =>
                Item(label: '', value: '')); // Return empty Item for phone

        return phone.value!.isNotEmpty; // Check if phone value is not empty
      });
    }

    setState(() {
      contactsFiltered = _contacts;
    });
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
      dialougeBox(context, "Maybe Contacts don't exist on this device");
    }
  }

  getAllContacts() async {
    List<Contact> _contacts =
        await ContactsService.getContacts(withThumbnails: false);
    setState(() {
      contacts = _contacts;
      contactsFiltered =
          _contacts; // Initialize filtered list with all contacts
      loading = false; // Contacts have been loaded, so stop loading
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isSearching = searchController.text.isNotEmpty;
    bool listItemExist = contactsFiltered.isNotEmpty;

    return Scaffold(
      body: loading
          ? const Center(
              child:
                  CircularProgressIndicator()) // Show loading indicator while fetching contacts
          : SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      autofocus: true,
                      controller: searchController,
                      decoration: const InputDecoration(
                        labelText: "Search Contact",
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                  ),
                  listItemExist
                      ? Expanded(
                          child: ListView.builder(
                            itemCount: isSearching
                                ? contactsFiltered.length
                                : contacts.length,
                            itemBuilder: (BuildContext context, int index) {
                              Contact contact = isSearching
                                  ? contactsFiltered[index]
                                  : contacts[index];
                              return ListTile(
                                title: Text(
                                  contact.displayName ?? 'Unknown Number',
                                ),
                                subtitle: Text(
                                  contact.phones!.isNotEmpty
                                      ? contact.phones!.elementAt(0).value!
                                      : 'No phone number',
                                ),
                                leading: (contact.avatar != null &&
                                        contact.avatar!.isNotEmpty)
                                    ? CircleAvatar(
                                        backgroundColor: primaryColor,
                                        backgroundImage:
                                            MemoryImage(contact.avatar!),
                                      )
                                    : CircleAvatar(
                                        backgroundColor: primaryColor,
                                        child: Text(contact.initials()),
                                      ),
                                onTap: () {
                                  if (contact.phones!.length > 0) {
                                    final String phoneNum =
                                        contact.phones!.elementAt(0).value!;
                                    final String name = contact.displayName!;
                                    _addContact(TContact(phoneNum, name));
                                  } else {
                                    Fluttertoast.showToast(
                                        msg:
                                            "Opps!! Phone Number Of this contact doesn't Exist");
                                  }
                                },
                              );
                            },
                          ),
                        )
                      : const Center(
                          child: Text("No contacts found."),
                        ),
                ],
              ),
            ),
    );
  }

  void _addContact(TContact newContact) async {
    int result = await _databaseHelper.insertContact(newContact);
    if (result != 0) {
      Fluttertoast.showToast(msg: "Contact Added Successfully");
    } else {
      Fluttertoast.showToast(msg: "Failed To Add Contact");
    }
    Navigator.of(context).pop(true);
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
