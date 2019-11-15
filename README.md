# nat_info

A package to get public IP of nat and derive its port mapping scheme.

When developing peer to peer systems one of the main obstacles faced is dealing with NATs.
THis package aims to reveal information about the NAT that the device is behind as well as how the
NAT deals with the mapping of ports with regards to port forwarding.

## Usage
To use this plugin, add `nat_info` as a [dependency in your pubspec.yaml file](https://flutter.io/platform-plugins/).

## Example

``` dart
import 'package:nat_info/nat_info.dart';

void main() async {
  NATInfo state = await getNATInfo();
  print(state);
}
```

This will print out a report similar to this

```
connected:true
public IP:InternetAddress('149.252.79.63', IPv4)
NAT mapping:Direct
NAT mapping certainty:1.0

```

## NATInfo

The `NATInfo` object contains 4 fields. The `connected` field is a boolean corresponding to the
existence of a valid internet connection. The `publicAddress` field contains the internet facing
address of this device. The `natMapping` field is either `Direct` or `Random` depending on whether
the NAT maps port directly from this device to its outward facing ports or whether the assignment
is random. The `mappingCertainty` field contains a certainty from 0 to 1 about how sure the package
is about the mapping being `Direct` or `Random`.