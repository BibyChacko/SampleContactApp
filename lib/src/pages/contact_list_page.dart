import 'package:contact_application/src/utils/launcher_utility.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class ContactListPage extends StatefulWidget {
  const ContactListPage({Key? key}) : super(key: key);

  @override
  _ContactListPageState createState() => _ContactListPageState();
}

class _ContactListPageState extends State<ContactListPage> {

  List<Contact> contacts = [];
  bool isLoading = true;
  @override
  void initState() {
    setPermission();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Contact App"),
      ),
      body: SafeArea(
        child: Visibility(
          visible: !isLoading,  // isLoading = false , visible = true
          replacement: const Center(child: CupertinoActivityIndicator()),
          child: Visibility(
            visible: contacts.isNotEmpty,
            replacement: const Text("No contacts found!!!"),
            child: ListView.builder(
              itemCount: contacts.length,
              itemBuilder: (context,pos){
                Contact itemContact = contacts[pos];
                String phone = "";
                if(itemContact.phones!=null){
                  phone = itemContact.phones?.map((e) => e.value).toSet().join(",") ?? "";
                }
                return ListTile(
                  onTap: (){
                    callContact(itemContact);
                  },
                  leading: CircleAvatar(
                    radius: 20,
                    child: Text(itemContact.initials()),
                  ),
                  title: Text("${itemContact.displayName}"),
                  subtitle: Text(phone),
                );
              },
            ),
          ),
        )
      ),
    );
  }

  Future<void> setPermission() async{
     PermissionStatus permissionStatus =  await  Permission.contacts.request();
     if(permissionStatus.isGranted){
        List<Contact> contactsTemp = await ContactsService.getContacts();
        setState(() {
          contacts = contactsTemp;
          isLoading = false;
        });
     }else{
       setState(() {
         isLoading = false;
       });
     }
  }

  void callContact(Contact itemContact) {
    if(itemContact.phones==null){
      return;
    }
    else if(itemContact.phones!.isEmpty){
      return;
    }
    else if(itemContact.phones?.length == 1){
      LauncherUtility.makeCall("${itemContact.phones!.first.value}");
      return;
    }else{
      showPhoneSelectorDialog(itemContact.phones!); //
    }
  }

  void showPhoneSelectorDialog(List<Item> phones) {
    showCupertinoDialog(context: context,
        builder: (context){
            return AlertDialog(
              title: const Text("Choose the number"),
              content: ListView.builder(
                itemCount: phones.length,
                shrinkWrap: true,
                itemBuilder: (_,pos){
                  return ListTile(
                    onTap: (){
                      LauncherUtility.makeCall("${phones[pos].value}");
                    },
                    title: Text("${phones[pos].value}"),
                  );
                },
              ),
            );
        });
  }

}
