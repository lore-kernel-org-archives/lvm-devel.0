From: mtanino <mtanino@redhat.com>
Date: Wed, 02 Apr 2014 16:04:07 -0400
Subject: [Question] Nested logical volume snapshot on shared storage volume
Message-ID: <533C6D37.4000901@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi

I would like to know latest activity of nested logical volume snapshot.
In my understanding, nested LV snapshot is only supported when we use 
LVM thin volume.
Referring the document, thin volume are not supported across the nodes 
in a cluster or shared with several servers. Therefore, there is no 
feature to provide nested LV snapshot across several nodes.

https://access.redhat.com/site/documentation/en-US/Red_Hat_Enterprise_Linux/6/html/Logical_Volume_Manager_Administration/thinprovisioned_volumes.html

I think nested logical volume snapshot is very useful feature for cloud 
environment.
For example,
If user create a new VM from LV snapshot, the VM can boot quickly 
because LVM snapshot is ablle to create rapidly and also it can save 
disk usage.
And if nested LV snapshot is supported, user can retrieve a VM which is 
created by LV snapshot to former state after applying some 
configurations. Nested snapshot is already supported by qcow2.

Following figure is shown above example.
I would appreciate if anyone let me know an activity of nested snapshot.

---------
* Mgmt node(serv01): Manage. volume creation using snapshot, volume deletion
                      snapshot creation using nested LVM snapshot, 
snapshot deletion
* HV node1(srv02)  : Attach a snapshot to a VM and run KVM guest.
* HV node2(srv03)  : Same as HV node1.
   thX: thin volume including KVM guest boot image.
  snX: snapshot from thin volume.

+---------------+  +---------------+  +---------------+
|     srv01     |  |     srv02     |  |     srv03     |
|   Mgmt node   |  |    HV node1   |  |    HV node2   |
|               |  |       +---+   |  |         +---+ |
|               |  |       |VM1|   |  |         |VM2| |
|               |  |       +-+-+   |  |         +-+-+ |
|               |  |         |     |  |             | |
+---+---+---+---+  +---+---+-+-+---+  +---+---+---+-+-+
|th1|th2|sn1|sn2|  |th1|th2|sn1|sn2|  |th1|th2|sn1|sn2|
+---------------+  +---------------+  +---------------+
|   dm-thin01   |  |   dm-thin01   |  |   dm-thin01   |
+---------------+  +---------------+  +---------------+
|     vg01      |  |     vg01      |  |     vg01      |
+---------------+  +---------------+  +---------------+
       |FC1               |FC2               |FC3
       |                  |                  |
------+------------------+--------+---------+----------
                                   |
                           +-------+--------+
                           | A Logical Unit |
                           +----------------+

-- 
Regards,
Mitsuhiro Tanino


