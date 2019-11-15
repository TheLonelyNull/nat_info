library nat_info;

import 'dart:io';
import 'package:convert/convert.dart';
import 'dart:async';
import 'dart:math';

/// Gets the nat information by making use of stun servers
Future<NATInfo> getNATInfo() async {
  const stun_servers = [
    "216.58.203.222",
    "172.217.27.190",
    "216.58.197.94",
    "74.125.200.127"
  ];
  //defined packet as per RFC5389
  List<int> packet = hex.decode("000100002112A442000000100010111111111111");
  //set up udp sockets
  List<RawDatagramSocket> sockets = new List();
  int startPort = 44444;
  List<List<int>> results = List(stun_servers.length);
  for (int i = 0; i < stun_servers.length; i++) {
    RawDatagramSocket.bind(InternetAddress.anyIPv4, startPort + i)
        .then((RawDatagramSocket socket) {
      //send packet
      socket.send(packet, InternetAddress(stun_servers[i]), 19302);
      //listen for reply
      socket.listen((RawSocketEvent e) {
        sockets.add(socket);
        if (e == RawSocketEvent.read) {
          Datagram reply = socket.receive();
          results[i] = reply.data;
        }
      }).onError((error) {
        //probably no internet. This will leave results null
      });
    });
  }
  //get results after timer
  await pause(const Duration(seconds: 1));
  //close sockets
  for (int i = 0; i < sockets.length; i++) {
    sockets[i].close();
  }
  //process results
  return new NATInfo(results);
}

Future pause(Duration d) => new Future.delayed(d);

/// An object to represent the nat information
class NATInfo {
  String natMapping;
  double mappingCertainty;
  InternetAddress publicAddress;
  bool connected;

  NATInfo(List<List<int>> data) {
    int nullCount = 0;
    int directMapped = 0;
    int randomMapped = 0;
    connected = true;


    int startPort = 44444;
    for (int i = 0; i < data.length; i++) {
      if (data[i] == null) {
        nullCount++;
      } else {
        if (publicAddress == null) {
          publicAddress = _extractAddress(data[i]);
        }
        if (_extractPort(data[i]) == startPort + i) {
          directMapped++;
        } else {
          randomMapped++;
        }
      }
    }

    if (nullCount == data.length) {
      //no internet
      connected = false;
    } else {
      if (directMapped == data.length || randomMapped == data.length) {
        mappingCertainty = 1;
      } else if (directMapped == randomMapped) {
        mappingCertainty = 0.5;
      } else {
        mappingCertainty = max(directMapped, randomMapped) / (directMapped+randomMapped);
      }

      if (directMapped >= randomMapped) {
        natMapping = "Direct";
      } else {
        natMapping = "Random";
      }
    }
  }

  String toString() => "connected:$connected\npublic IP:$publicAddress\nNAT mapping:$natMapping\nNAT mapping certainty:$mappingCertainty";

  int _extractPort(List<int> packet) {
    List<int> magic = hex.decode("2112");
    List<int> port = List(2);
    for (int i = 26; i < 28; i++) {
      port[i - 26] = packet[i] ^ magic[i - 26];
    }
    int portNumber = port[0] << 8;
    portNumber += port[1];
    return portNumber;
  }

  InternetAddress _extractAddress(List<int> packet) {
    List<int> magic = hex.decode("2112A442"); //magic number as per RFC5389
    //packet length is 32 bytes, last 4 bytes contain the ipv4 address.
    //Extracting the XOR-Mapped address
    List<int> address = List(4);
    for (int i = 28; i < 32; i++) {
      address[i - 28] = packet[i] ^ magic[i - 28];
    }
    //turn the list into a string to be given as argument to InternetAddress
    String addressString = "";
    for (int j = 0; j < 4; j++) {
      addressString += address[j].toString();
      if (j != 3) {
        addressString += ".";
      }
    }
    return InternetAddress(addressString);
  }
}
