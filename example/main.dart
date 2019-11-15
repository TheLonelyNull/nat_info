import 'package:nat_info/nat_info.dart';

void main() async {
  //simply run this to get an object representing the NAT
  NATInfo info = await getNATInfo();
  //the toString method also provides an easy to read text report
  print(info);
}