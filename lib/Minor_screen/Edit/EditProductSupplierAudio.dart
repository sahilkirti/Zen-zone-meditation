import 'dart:io';
import 'dart:typed_data';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:final2/Utilities/Category.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

import '../../Screens/Upload/Upload.dart';

List<String> category = [
  'Focus',
  'Podcast',
  'Sleep',
  'Deep Focus',
  'Kids',
  'Productivity',
  'Ambient Sound',
  'Free'
];

File? file;

class EditProductSupplierAudio extends StatefulWidget {
  final dynamic item;

  const EditProductSupplierAudio({Key? key, required this.item})
      : super(key: key);
  static const String id = '/Upload_product_screen';

  @override
  State<EditProductSupplierAudio> createState() =>
      _EditProductSupplierAudioState();
}

class _EditProductSupplierAudioState extends State<EditProductSupplierAudio> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late double price;
  late int quantity;
  late String proName;
  late String proDesc;
  late String prodId;
  bool processing = false;
  String mainCategValue = 'Focus';
  List<XFile>? _imageFileList = [];
  List<dynamic> _imageUrlList = [];
  dynamic _pickImageError;
  UploadTask? task;
  late String url;

  void _pickProductImages() async {
    try {
      final pickedImages = await ImagePicker().pickMultiImage(
        maxHeight: 300,
        maxWidth: 300,
        imageQuality: 96,
      );
      setState(() {
        _imageFileList = pickedImages!;
      });
    } catch (e) {
      setState(() {
        _pickImageError = e;
      });
      print(_pickImageError);
    }
  }

  Future selectFile() async {
    final result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        allowedExtensions: ['mp3'],
        type: FileType.custom);
    if (result == null) return;
    final path = result.files.single.path!;
    setState(() => file = File(path));
  }

  Future uploadFile() async {
    if (file == null) return;
    final fileName = path.basename(file!.path);
    final destination = 'Audio/$fileName';
    task = FirebaseApi.uploadFile(destination, file!);
    if (task == null) return;
    final snapshot = await task!.whenComplete(() {});
    String Url = await snapshot.ref.getDownloadURL();
  }

  Future uploadAudio() async {
    if (file == null) return;
    final fileName = path.basename(file!.path);
    final destination = 'Audio/$fileName';
    var pdfFile = FirebaseStorage.instance.ref(destination);
    firebase_storage.UploadTask task = pdfFile.putFile(file!);
    TaskSnapshot snapshot = await task;
    url = await snapshot.ref.getDownloadURL();
  }

  Widget previewImages() {
    if (_imageFileList!.isNotEmpty) {
      return ListView.builder(
          itemCount: _imageFileList!.length,
          itemBuilder: (context, index) {
            return Image.file(File(_imageFileList![index].path));
          });
    } else {
      return const Center(
        child: Text('you have not \n \n picked images yet !',
            textAlign: TextAlign.center, style: TextStyle(fontSize: 16)),
      );
    }
  }

  Widget previewCurrentImages() {
    List<dynamic> itemImages = widget.item['proimages'];
    return ListView.builder(
        itemCount: itemImages.length,
        itemBuilder: (context, index) {
          return Image.network(itemImages[index].toString());
        });
  }

  Widget buildUploadStatus(UploadTask task) => StreamBuilder<TaskSnapshot>(
        stream: task.snapshotEvents,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final snap = snapshot.data!;
            final progress = snap.bytesTransferred / snap.totalBytes;
            final percentage = (progress * 100).toStringAsFixed(2);

            return Text(
              '$percentage %',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            );
          } else {
            return Container();
          }
        },
      );

  // Future<void> uploadImages() async {
  //   if (_formKey.currentState!.validate()) {
  //     _formKey.currentState!.save();
  //     if (_imageFileList!.isNotEmpty) {
  //       setState(() {
  //         processing = true;
  //       });
  //       try {
  //         for (var image in _imageFileList!) {
  //           firebase_storage.Reference ref = firebase_storage
  //               .FirebaseStorage.instance
  //               .ref('product/${path.basename(image.path)}');
  //           await ref.putFile(File(image.path)).whenComplete(() async {
  //             await ref.getDownloadURL().then((value) {
  //               _imageUrlList.add(value);
  //             });
  //           });
  //         }
  //       } catch (e) {
  //         print(e);
  //       }
  //       setState(() {
  //         _imageFileList = [];
  //       });
  //       _formKey.currentState!.reset();
  //     } else {
  //       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //         elevation: 0,
  //         behavior: SnackBarBehavior.floating,
  //         backgroundColor: Colors.transparent,
  //         content: AwesomeSnackbarContent(
  //           title: 'On Snap!',
  //           message: 'Please pick images first',
  //           contentType: ContentType.failure,
  //         ),
  //       ));
  //     }
  //   } else {
  //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //       elevation: 0,
  //       behavior: SnackBarBehavior.floating,
  //       backgroundColor: Colors.transparent,
  //       content: AwesomeSnackbarContent(
  //         title: 'On Snap!',
  //         message: 'Please Enter all the fields Properly',
  //         contentType: ContentType.failure,
  //       ),
  //     ));
  //   }
  // }
  //
  // void uploadData() async {
  //   if (_imageUrlList.isNotEmpty) {
  //     CollectionReference productRef =
  //         FirebaseFirestore.instance.collection('products');
  //     prodId = const Uuid().v4();
  //     await productRef.doc(prodId).set({
  //       'proid': prodId,
  //       'maincateg': mainCategValue,
  //       'price': price,
  //       'instock': quantity,
  //       'proname': proName,
  //       'prodesc': proDesc,
  //       'sid': FirebaseAuth.instance.currentUser!.uid,
  //       'proimages': _imageUrlList,
  //       'discount': 0,
  //       'AudioUrl': url,
  //     }).whenComplete(() {
  //       setState(() {
  //         processing = false;
  //         _imageFileList = [];
  //         mainCategValue = 'Focus';
  //         _imageUrlList = [];
  //       });
  //       _formKey.currentState!.reset();
  //     });
  //   } else {
  //     print('No Images');
  //   }
  // }
  //
  // void uploadProduct() async {
  //   await uploadAudio().then((value) => uploadImages()).whenComplete(() {
  //     uploadData();
  //   });
  // }

  uploadImages() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      if (_imageFileList!.isNotEmpty) {
        try {
          for (var image in _imageFileList!) {
            firebase_storage.Reference ref = firebase_storage
                .FirebaseStorage.instance
                .ref('product/${path.basename(image.path)}');
            await ref.putFile(File(image.path)).whenComplete(() async {
              await ref.getDownloadURL().then((value) {
                _imageUrlList.add(value);
              });
            });
          }
        } catch (e) {
          print(e);
        }
      } else {
        _imageFileList = widget.item['proimages'];
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: 'On Snap!',
          message: 'Please Enter all the fields Properly',
          contentType: ContentType.failure,
        ),
      ));
    }
  }

  editProductData() async {
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentReference documentReference = FirebaseFirestore.instance
          .collection('products')
          .doc(widget.item['proid']);
      transaction.update(documentReference, {
        'maincateg': mainCategValue,
        'price': price,
        'instock': quantity,
        'proname': proName,
        'prodesc': proDesc,
        'proimages': _imageUrlList,
        'discount': 0,
      });
    }).whenComplete(() => Navigator.pop(context));
  }

  saveChanges() async {
    await uploadImages().whenComplete(() => editProductData());
  }

  @override
  Widget build(BuildContext context) {
    var filename =
        file != null ? path.basename(file!.path) : 'No Audio Selected';
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          'Upload',
          style: GoogleFonts.abyssinicaSil(
              color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          reverse: true,
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          physics: BouncingScrollPhysics(),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                SizedBox(
                  height: 2,
                ),
                Row(children: [
                  Stack(children: [
                    Container(
                      color: Colors.grey,
                      height: MediaQuery.of(context).size.width * 0.5,
                      width: MediaQuery.of(context).size.width * 0.5,
                      child: previewCurrentImages(),
                    )
                  ]),
                  Container(
                    height: MediaQuery.of(context).size.width * 0.5,
                    width: MediaQuery.of(context).size.width * 0.5,
                    padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.width * 0.20),
                    child: Column(
                      children: [
                        Container(
                            height: MediaQuery.of(context).size.height / 23,
                            width: MediaQuery.of(context).size.width / 2.5,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [
                                Color(0xffb2d5dd),
                                Color(0xffb7dfce),
                                Color(0xffafc2f9),
                              ]),
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(color: Colors.black, width: 2),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Center(
                                  child: Text(
                                    "Main Category",
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.abyssinicaSil(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 24,
                                        color: Colors.black),
                                  ),
                                )
                              ],
                            )),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                            height: MediaQuery.of(context).size.height / 23,
                            width: MediaQuery.of(context).size.width / 2.5,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [
                                Color(0xffb2d5dd),
                                Color(0xffb7dfce),
                                Color(0xffafc2f9),
                              ]),
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(color: Colors.black, width: 2),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Center(
                                  child: Text(
                                    widget.item['maincateg'],
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.abyssinicaSil(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 24,
                                        color: Colors.black),
                                  ),
                                )
                              ],
                            )),
                      ],
                    ),
                  )
                ]),
                SizedBox(
                  height: 10,
                ),
                ExpansionTile(
                  title: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [
                        Color(0xffb2d5dd),
                        Color(0xffb7dfce),
                        Color(0xffafc2f9),
                      ]),
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: Colors.black, width: 2),
                    ),
                    padding: const EdgeInsets.all(6),
                    child: const Center(
                      child: Text(
                        'Change Images & Categories',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  children: [
                    changeImages(),
                    Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(24, 10, 14, 10),
                          child: _imageFileList!.isNotEmpty
                              ? InkWell(
                                  onTap: () {
                                    setState(() {
                                      _imageFileList = [];
                                    });
                                  },
                                  child: Container(
                                      height:
                                          MediaQuery.of(context).size.height /
                                              20,
                                      width: MediaQuery.of(context).size.width /
                                          2.5,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(colors: [
                                          Color(0xffb2d5dd),
                                          Color(0xffb7dfce),
                                          Color(0xffafc2f9),
                                        ]),
                                        borderRadius: BorderRadius.circular(5),
                                        border: Border.all(
                                            color: Colors.black, width: 2),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Center(
                                            child: Text(
                                              "Reset",
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.abyssinicaSil(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 24,
                                                  color: Colors.black),
                                            ),
                                          ),
                                        ],
                                      )),
                                )
                              : GestureDetector(
                                  onTap: () {
                                    previewImages();
                                  },
                                  child: Container(
                                      height:
                                          MediaQuery.of(context).size.height /
                                              20,
                                      width: MediaQuery.of(context).size.width *
                                          .9,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(colors: [
                                          Color(0xffb2d5dd),
                                          Color(0xffb7dfce),
                                          Color(0xffafc2f9),
                                        ]),
                                        borderRadius: BorderRadius.circular(5),
                                        border: Border.all(
                                            color: Colors.black, width: 2),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Center(
                                            child: Text(
                                              "Change Image",
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.abyssinicaSil(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 24,
                                                  color: Colors.black),
                                            ),
                                          ),
                                        ],
                                      )),
                                ),
                        ),
                      ],
                    )
                  ],
                ),
                SizedBox(
                  height: 30,
                  child: Divider(
                    color: Colors.black,
                    thickness: 1,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: TextFormField(
                    initialValue: widget.item['price'].toStringAsFixed(2),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Please Enter Price";
                      } else if (value.isValidPrice() != true) {
                        return 'Invalid Price';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      price = double.parse(value!);
                    },
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: textFormDecoration.copyWith(
                        hintText: 'Enter a price for a product',
                        labelText: 'Price',
                        prefixIcon: Icon(
                          Icons.currency_rupee,
                          color: Colors.black,
                        )),
                  ),
                ),
                // Padding(
                //   padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                //   child: TextFormField(
                //     initialValue: widget.item['instock'].toString(),
                //     validator: (value) {
                //       if (value!.isEmpty) {
                //         return "Please Enter Quantity";
                //       } else if (value.isValidQuantity() != true) {
                //         ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                //           elevation: 0,
                //           behavior: SnackBarBehavior.floating,
                //           backgroundColor: Colors.transparent,
                //           content: AwesomeSnackbarContent(
                //             title: 'On Snap!',
                //             message: 'Please Enter valid Quantity',
                //             contentType: ContentType.failure,
                //           ),
                //         ));
                //       }
                //       return null;
                //     },
                //     onSaved: (value) {
                //       quantity = int.parse(value!);
                //     },
                //     keyboardType: TextInputType.number,
                //     decoration: textFormDecoration.copyWith(
                //         hintText: 'Add Quantity',
                //         labelText: 'Quantity',
                //         prefixIcon: Icon(
                //           Icons.production_quantity_limits_outlined,
                //           color: Colors.black,
                //         )),
                //   ),
                // ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: TextFormField(
                    initialValue: widget.item['proname'].toString(),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Please Enter Product Name";
                      }
                      return null;
                    },
                    maxLength: 100,
                    maxLines: 3,
                    onSaved: (value) {
                      proName = value!;
                    },
                    decoration: textFormDecoration.copyWith(
                        hintText: 'Enter Product Name',
                        labelText: 'Product Name',
                        prefixIcon: Icon(
                          Icons.drive_file_rename_outline_sharp,
                          color: Colors.black,
                        )),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                  child: TextFormField(
                    initialValue: widget.item['prodesc'].toString(),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Please Enter Product Description";
                      }
                      return null;
                    },
                    maxLength: 800,
                    maxLines: 5,
                    onSaved: (value) {
                      proDesc = value!;
                    },
                    decoration: textFormDecoration.copyWith(
                        hintText: 'Product Description',
                        labelText: 'Product Description',
                        prefixIcon: Icon(
                          Icons.description,
                          color: Colors.black,
                        )),
                  ),
                ),
                // Container(
                //   padding: EdgeInsets.all(20),
                //   child: Center(
                //     child: Column(
                //       mainAxisAlignment: MainAxisAlignment.start,
                //       children: [
                //         ButtonWidget(
                //           text: 'Select Audio',
                //           icon: Icons.attach_file,
                //           onClicked: selectFile,
                //         ),
                //         SizedBox(height: 8),
                //         Text(
                //           filename,
                //           style: TextStyle(
                //               fontSize: 16, fontWeight: FontWeight.w500),
                //         ),
                //         SizedBox(height: 15),
                //         // ButtonWidget(
                //         //   text: 'Upload File',
                //         //   icon: Icons.cloud_upload_outlined,
                //         //   onClicked: uploadFile,
                //         // ),
                //         // SizedBox(height: 15),
                //         task != null ? buildUploadStatus(task!) : Container(),
                //       ],
                //     ),
                //   ),
                // ),
                Column(
                  children: [
                    Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(24, 10, 14, 10),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Container(
                                height: MediaQuery.of(context).size.height / 20,
                                width: MediaQuery.of(context).size.width / 2.5,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(colors: [
                                    Color(0xffb2d5dd),
                                    Color(0xffb7dfce),
                                    Color(0xffafc2f9),
                                  ]),
                                  borderRadius: BorderRadius.circular(5),
                                  border:
                                      Border.all(color: Colors.black, width: 2),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Center(
                                      child: Text(
                                        "Cancel",
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.abyssinicaSil(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 24,
                                            color: Colors.black),
                                      ),
                                    ),
                                  ],
                                )),
                          ),
                        ),
                        Padding(
                            padding: EdgeInsets.fromLTRB(24, 10, 24, 10),
                            child: processing == true
                                ? Container(
                                    height:
                                        MediaQuery.of(context).size.height / 20,
                                    width:
                                        MediaQuery.of(context).size.width / 2.5,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(colors: [
                                        Color(0xffb2d5dd),
                                        Color(0xffb7dfce),
                                        Color(0xffafc2f9),
                                      ]),
                                      borderRadius: BorderRadius.circular(5),
                                      border: Border.all(
                                          color: Colors.black, width: 2),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Center(
                                          child: Text(
                                            "Please Wait ...",
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.abyssinicaSil(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 24,
                                                color: Colors.black),
                                          ),
                                        )
                                      ],
                                    ))
                                : GestureDetector(
                                    child: Container(
                                        height:
                                            MediaQuery.of(context).size.height /
                                                20,
                                        width:
                                            MediaQuery.of(context).size.width /
                                                2.5,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(colors: [
                                            Color(0xffb2d5dd),
                                            Color(0xffb7dfce),
                                            Color(0xffafc2f9),
                                          ]),
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          border: Border.all(
                                              color: Colors.black, width: 2),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Center(
                                              child: Text(
                                                "Save Changes",
                                                overflow: TextOverflow.ellipsis,
                                                style:
                                                    GoogleFonts.abyssinicaSil(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: 24,
                                                        color: Colors.black),
                                              ),
                                            )
                                          ],
                                        )),
                                    onTap: () {
                                      saveChanges();
                                    },
                                  )),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(24, 10, 14, 10),
                      child: GestureDetector(
                        onTap: () async {
                          await FirebaseFirestore.instance
                              .runTransaction((transaction) async {
                            DocumentReference documentReference =
                                FirebaseFirestore.instance
                                    .collection('products')
                                    .doc(widget.item['proid']);
                            transaction.delete(documentReference);
                          }).whenComplete(() => Navigator.pop(context));
                        },
                        child: Container(
                            height: MediaQuery.of(context).size.height / 20,
                            width: MediaQuery.of(context).size.width / 2.5,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [
                                Color(0xffb2d5dd),
                                Color(0xffb7dfce),
                                Color(0xffafc2f9),
                              ]),
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(color: Colors.black, width: 2),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Center(
                                  child: Text(
                                    "Delete Item",
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.abyssinicaSil(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 24,
                                        color: Colors.black),
                                  ),
                                ),
                              ],
                            )),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget changeImages() {
    return Row(children: [
      Stack(children: [
        Container(
          color: Colors.grey,
          height: MediaQuery.of(context).size.width * 0.5,
          width: MediaQuery.of(context).size.width * 0.5,
          child: _imageFileList != null
              ? previewImages()
              : const Center(
                  child: Text('you have not \n \n picked images yet !',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16)),
                ),
        ),
        _imageFileList!.isEmpty
            ? const SizedBox()
            : IconButton(
                onPressed: () {
                  setState(() {
                    _imageFileList = [];
                  });
                },
                icon: Icon(
                  Icons.delete_forever_outlined,
                  color: Colors.black,
                )),
      ]),
      Container(
        height: MediaQuery.of(context).size.width * 0.5,
        width: MediaQuery.of(context).size.width * 0.5,
        padding: EdgeInsets.only(top: MediaQuery.of(context).size.width * 0.20),
        child: Column(
          children: [
            const Text("Select Category"),
            DropdownButton(
                iconSize: 40,
                borderRadius: BorderRadius.circular(5),
                enableFeedback: true,
                elevation: 0,
                focusColor: Colors.black,
                dropdownColor: Colors.grey,
                menuMaxHeight: 500,
                icon: Icon(
                  Icons.arrow_drop_down_circle_outlined,
                  size: 30,
                ),
                disabledHint: const Text('select category'),
                value: mainCategValue,
                items: mainCateg.map<DropdownMenuItem<String>>((value) {
                  return DropdownMenuItem(
                    child: Text(value),
                    value: value,
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    mainCategValue = value!;
                  });
                })
          ],
        ),
      )
    ]);
  }
}

class TabsRepeated extends StatelessWidget {
  final String title;
  final Color colors;

  const TabsRepeated({
    super.key,
    required this.title,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final double size = MediaQuery.of(context).size.width as double;
    return Container(
      width: size * .33,
      decoration: BoxDecoration(
          color: Colors.black, borderRadius: BorderRadius.circular(5)),
      child: TextButton(
        child: SizedBox(
          height: 40,
          width: MediaQuery.of(context).size.width * 0.23,
          child: Center(
            child: Text(
              title,
              style: TextStyle(color: colors, fontSize: 20),
            ),
          ),
        ),
        onPressed: () {},
      ),
    );
  }
}

var textFormDecoration = InputDecoration(
    hintText: 'Price',
    labelText: 'Price',
    floatingLabelStyle: TextStyle(color: Colors.black),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(5),
      borderSide: BorderSide(color: Colors.grey),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(5),
      borderSide: BorderSide(color: Colors.black),
    ),
    prefixIcon: Icon(Icons.phone, color: Colors.black),
    suffixIconColor: Colors.black);

extension QuantityValidator on String {
  bool isValidQuantity() {
    return RegExp(r'^[1-9][0-9]*$').hasMatch(this);
  }
}

extension PriceValidator on String {
  bool isValidPrice() {
    return RegExp(r'^((([1-9][0-9]*[\.]*)||([0][\.]*))([0-9]{1,2}))$')
        .hasMatch(this);
  }
}

extension DiscountValidator on String {
  bool isValidDiscount() {
    return RegExp(r'^([0-9]*)$').hasMatch(this);
  }
}

class FirebaseApi {
  static UploadTask? uploadFile(String destination, File file) {
    try {
      final ref = FirebaseStorage.instance.ref(destination);
      return ref.putFile(file);
    } on FirebaseException catch (e) {
      return null;
    }
  }

  static UploadTask? uploadBytes(String destination, Uint8List data) {
    try {
      final ref = FirebaseStorage.instance.ref(destination);

      return ref.putData(data);
    } on FirebaseException catch (e) {
      return null;
    }
  }
}
