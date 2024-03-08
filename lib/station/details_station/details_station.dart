// Import necessary packages and libraries

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

//This Page Will Display The Details Of Station -------------------

// Widget for displaying details of a specific station
class DetailsStation extends StatelessWidget {
  const DetailsStation({required this.id});
  final id;

  // StreamBuilder to listen for changes in the Firestore document
  firestoreStream() {
    return StreamBuilder<DocumentSnapshot>(
      stream:
          FirebaseFirestore.instance.collection('Station').doc(id).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        if (snapshot.hasData) {
          var data = snapshot.data?.data() as Map<String, dynamic>;
          if (data != null) {
            return buildContent(data);
          } else {
            return Text('No data available');
          }
        }
        return Text('No data available');
      },
    );
  }

  // Build the content of the screen based on the Firestore data
  Widget buildContent(Map<String, dynamic> data) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            SizedBox(
              width: double.infinity,
              child: Image.network(data['image_station']),
            ),
            scroll(data),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF6EA67C),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Station details',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: firestoreStream(),
    );
  }

  // Build the draggable scrollable sheet for additional station details
  scroll(Map<String, dynamic> data) {
    List<String> service = [
      'car wash',
      'shop',
      'coffee'
    ]; // WILL BE REMOVED IN SPRINT 4 "DUMMY DATA"

    return DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 1.0,
        minChildSize: 0.6,
        builder: (context, scrollController) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: const BoxDecoration(
              color: Color(0xFF6EA67C),
              borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20)),
            ),
            child: SingleChildScrollView(
              controller: scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 25),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 5,
                          width: 35,
                          color: Color.fromARGB(255, 193, 195, 194),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    data['name'],
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          fontSize: 40.0,
                          fontFamily: 'NanumGothic',
                        ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Open hour: ' +
                              data['open_hour'] +
                              getAmOrPmIndicator(data['open_hour']) +
                              "     Close hour: " +
                              data['close_hour'] +
                              getAmOrPmIndicator(data['close_hour']),
                          style:
                              Theme.of(context).textTheme.bodyMedium!.copyWith(
                                    color: Colors.black,
                                  ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      GestureDetector(
                        onTap: () async {
                          var googleMapsUrl = data['location'];
                          if (await canLaunch(googleMapsUrl)) {
                            await launch(googleMapsUrl);
                          } else {
                            throw 'Could not launch $googleMapsUrl';
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color.fromARGB(255, 211, 166, 42),
                          ),
                          child: Icon(
                            Icons.map,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    child: Divider(
                      height: 4,
                    ),
                  ),
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Fuel Available Now:",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(color: Colors.black)),
                        ],
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: buildFuelIcons(data['fuel_status']),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    child: Divider(
                      height: 4,
                    ),
                  ),
                  Text(
                    "Services",
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          fontSize: 40.0,
                          fontFamily: 'NanumGothic',
                        ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: 1,
                    itemBuilder: (context, index) => Services(context, service),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    child: Divider(
                      height: 4,
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  // Function to display services
  Services(BuildContext context, List<dynamic> services) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var service in services)
            Row(
              children: [
                const CircleAvatar(
                  radius: 10,
                  backgroundColor: Color(0xFFE3FFF8),
                  child: Icon(
                    Icons.done,
                    size: 15,
                    color: Color(0xFF0C9869),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  service,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: Colors.black,
                      ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  // Function to display promotion
  Widget Promotion(BuildContext context, List<dynamic> promotion) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (promotion.isEmpty)
            Text(
              "No promotion in station",
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: Colors.black,
                  ),
            )
          else
            for (var pro in promotion)
              Row(
                children: [
                  const CircleAvatar(
                    radius: 10,
                    child: Icon(
                      Icons.auto_awesome,
                      size: 15,
                      color: Color.fromARGB(255, 214, 242, 143),
                    ),
                  ),
                  SizedBox(
                    width: 270,
                    child: Text(
                      pro,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium!
                          .copyWith(color: Color.fromARGB(255, 250, 252, 254)),
                    ),
                  ),
                ],
              ),
          const SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }

  // Function to get AM or PM indicator based on time
  String getAmOrPmIndicator(String timeString) {
    int hour = int.parse(timeString.split(":")[0]);
    return hour < 12 ? 'AM' : 'PM';
  }

  // Function to build fuel icons based on availability
  List<Widget> buildFuelIcons(List<dynamic> fuelTypeData) {
    List<Widget> fuelIcons = [];
    bool isFuelAvailable = false;
    for (var fuelType in fuelTypeData) {
      if (fuelType.substring(0, 2) == '91' &&
          fuelType.substring(3, 12) == 'Available') {
        fuelIcons.add(
          SvgPicture.asset(
            'assets/icons/91A.svg',
            width: 45,
            height: 45,
          ),
        );
        isFuelAvailable = true;
      } else if (fuelType.substring(0, 2) == '95' &&
          fuelType.substring(3, 12) == 'Available') {
        fuelIcons.add(
          SvgPicture.asset(
            'assets/icons/95A.svg',
            width: 45,
            height: 45,
          ),
        );
        isFuelAvailable = true;
      } else if (fuelType.substring(0, 6) == 'Diesel' &&
          fuelType.substring(7, 16) == 'Available') {
        fuelIcons.add(SvgPicture.asset(
          'assets/icons/DA.svg',
          width: 45,
          height: 45,
        ));
        isFuelAvailable = true;
      }
    }
    if (!isFuelAvailable) {
      fuelIcons.add(SvgPicture.asset(
        'assets/icons/not.svg',
        width: 45,
        height: 45,
      ));
    }
    return fuelIcons;
  }
}