# UDP hole punching
https://en.wikipedia.org/wiki/UDP_hole_punching

UDP hole punching establishes connectivity between two hosts communicating across one or more network address translators. Typically, third-party hosts on the public transit network are used to establish UDP port states that may be used for direct communications between the communicating hosts. Once port state has been successfully established and the hosts are communicating, port state may be maintained either by normal communications traffic, or in the prolonged absence thereof, by keep-alive packets, usually consisting of empty UDP packets or packets with minimal non-intrusive content. 

# Flow
Let A and B be the two hosts, each in its own private network; NA and NB are the two NAT devices with globally reachable IP addresses EIPA and EIPB respectively; S is a public server with a well-known, globally reachable IP address.

- A and B each begin a UDP conversation with S; the NAT devices NA and NB create UDP translation states and assign temporary external port numbers EPA and EPB.
- S examines the UDP packets to get the source port used by NA and NB (the external NAT ports EPA and EPB).
- S passes EIPA:EPA to B and EIPB:EPB to A.
- A sends a packet to EIPB:EPB.
- NA examines A's packet and creates the following tuple in its translation table: (Source-IP-A, EPA, EIPB, EPB).
- B sends a packet to EIPA:EPA.
- NB examines B's packet and creates the following tuple in its translation table: (Source-IP-B, EPB, EIPA, EPA).
- Depending on the state of NA's translation table when B's first packet arrives (i.e. whether the tuple (Source-IP-A, EPA, EIPB, EPB) has been created by the time of arrival of B's first packet), B's first packet is dropped (no entry in translation table) or passed (entry in translation table has been made).
- Depending on the state of NB's translation table when A's first packet arrives (i.e. whether the tuple (Source-IP-B, EPB, EIPA, EPA) has been created by the time of arrival of A's first packet), A's first packet is dropped (no entry in translation table) or passed (entry in translation table has been made).
- At worst, the second packet from A reaches B; at worst the second packet from B reaches A. Holes have been "punched" in the NAT and both hosts can directly communicate.

If both hosts have Restricted cone NATs or Symmetric NATs, the external NAT ports will differ from those used with S. On some routers, the external ports are picked sequentially, making it possible to establish a conversation through guessing nearby ports.

# Abstract
https://bford.info/pub/net/p2pnat/

Network Address Translation (NAT) causes well-known difficulties for peer-to-peer (P2P) communication, since the peers involved may not be reachable at any globally valid IP address. Several NAT traversal techniques are known, but their documentation is slim, and data about their robustness or relative merits is slimmer. This paper documents and analyzes one of the simplest but most robust and practical NAT traversal techniques, commonly known as “hole punching.” Hole punching is moderately well-understood for UDP communication, but we show how it can be reliably used to set up peer-to-peer TCP streams as well. After gathering data on the reliability of this technique on a wide variety of deployed NATs, **we find that about 82% of the NATs tested support hole punching for UDP, and about 64% support hole punching for TCP streams**. As NAT vendors become increasingly conscious of the needs of important P2P applications such as Voice over IP and online gaming protocols, support for hole punching is likely to increase in the future. 
