import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jobfinder/Search/search_job.dart';
import 'package:jobfinder/Widgets/job_widget.dart';
//import 'package:jobfinder/user_state.dart';

import '../Persistent/persistent.dart';
import '../Widgets/bottom_nav_bar.dart';


class JobScreen extends StatefulWidget {

  @override
  State<JobScreen> createState() => _JobScreenState();
}

class _JobScreenState extends State<JobScreen> {

  String? _jobCategoryfilter;
  final FirebaseAuth _auth =FirebaseAuth.instance;

  _showTaskCategoriesDialog ({required Size size})
  {
    showDialog(
        context: context,
        builder: (ctx)
        {
          return AlertDialog(
            backgroundColor: Colors.black54,
            title: const Text(
              'Job Category',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white,fontSize: 20),
            ),
            content: Container(
              width: size.width * 0.9,
              child: ListView.builder(
                itemBuilder: (ctx,index)
                {
                  return InkWell(
                    onTap: (){
                      setState(() {
                        _jobCategoryfilter =Persistent.jobCategoryList[index];
                      });
                      Navigator.canPop(context)? Navigator.pop(context): null;
                      print(
                        'jobCategoryList[index] ,${Persistent.jobCategoryList[index]}'
                      );
                    },
                    child: Row(
                      children: [
                        const Icon(
                          Icons.arrow_right_alt_outlined,
                          color: Colors.grey,
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            Persistent.jobCategoryList[index],
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                        )
                      ],
                    ),
                  );
                },
                shrinkWrap: true,
                itemCount: Persistent.jobCategoryList.length,
              ),
            ),
            actions: [
              TextButton(
                onPressed: ()
                {
                  Navigator.canPop(context) ? Navigator.pop(context): null;
                },
                child: const Text(
                  'Close',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
              TextButton(
                  onPressed: (){
                    setState(() {
                      _jobCategoryfilter =null;
                    });
                    Navigator.canPop(context) ? Navigator.pop(context): null;
                  },
                  child: const Text('Cancel Filter',style: TextStyle(color: Colors.white),)
              ),
            ],
          );
        }
    );
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Persistent persistentObject = Persistent();
    persistentObject.getMyData();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepOrange.shade300,Colors.blueAccent],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          stops: const [0.2,0.9],
        )
      ),
      child: Scaffold(
        bottomNavigationBar: BottomNavBar(indexNum:0),
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          flexibleSpace: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.deepOrange.shade300,Colors.blueAccent],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  stops: const [0.2,0.9],
                ),
            ),
          ),
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(Icons.filter_list_rounded,color: Colors.black,),
            onPressed: (){
              _showTaskCategoriesDialog(size: size);
            },
          ),
          actions: [
            IconButton(
                onPressed: (){
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (c)=> SearchScreen()));
                },
                icon:Icon(Icons.search_outlined,color: Colors.black,),
            )
          ],
        ),
        body: StreamBuilder<QuerySnapshot<Map<String,dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('Jobs')
              .where('jobCategory',isEqualTo: _jobCategoryfilter)
              .where('recruitment',isEqualTo: true)
              .orderBy('createdAt',descending: false)
              .snapshots(),
          builder: (context,AsyncSnapshot snapshot)
          {
            if(snapshot.connectionState==ConnectionState.waiting){
              return const Center(child: CircularProgressIndicator(),);
            }
            else if(snapshot.connectionState==ConnectionState.active){
              if(snapshot.data?.docs.isNotEmpty==true){
                return ListView.builder(
                  itemCount: snapshot.data?.docs.length,
                  itemBuilder: (BuildContext context ,int index){
                    return JobWidget(
                      jobTitle: snapshot.data?.docs[index]['jobTitle'],
                      jobDescription: snapshot.data?.docs[index]['jobDescription'],
                      jobId: snapshot.data?.docs[index]['jobId'],
                      uploadedBy: snapshot.data?.docs[index]['uploadedBy'],
                      userImage: snapshot.data?.docs[index]['userImage'],
                      name: snapshot.data?.docs[index]['name'],
                      recruitment: snapshot.data?.docs[index]['recruitment'],
                      email:snapshot.data?.docs[index]['email'],
                      location: snapshot.data?.docs[index]['location'],
                    );
                  }
                );
              }
              else
                {
                  return const Center(
                    child: Text('There is no jobs '),
                  );
                }
            }
            return const Center(
              child: Text(
                'Something went wrong',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 30
                ),
              ),
            );
          }
        )
    ),
    );
  }
}
