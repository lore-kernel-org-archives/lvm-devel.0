From: Dave Wysochanski <dwysocha@redhat.com>
Date: Fri, 24 Aug 2007 13:01:02 -0400
Subject: vgremove -f option add
In-Reply-To: <1187902565.4547.15.camel@linux-cxyg>
References: <0JMI00FL0XLWQOB0@mta.telcel.com>
	<1187902565.4547.15.camel@linux-cxyg>
Message-ID: <1187974862.4339.20.camel@linux-cxyg>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Thu, 2007-08-23 at 16:56 -0400, Dave Wysochanski wrote:

> I did some cleanup work first and I've attached an updated patch against
> the latest code.  Patch was tested against a simple cluster as well as
> single node and seems to work fine.  Some sample output in a clustered
> environment:
> 
> # lvs
>   LV       VG         Attr   LSize  Origin Snap%  Move Log Copy% 
>   LogVol00 VolGroup00 -wi-ao  5.84G                              
>   LogVol01 VolGroup00 -wi-ao  1.03G                              
>   lv0      vg0        -wi-a- 96.00M                              
> # vgs
>   VG         #PV #LV #SN Attr   VSize   VFree  
>   VolGroup00   1   2   0 wz--n-   6.91G  32.00M
>   vg0          5   1   0 wz--nc 240.00M 144.00M
> # vgremove vg0
> Do you really want to remove volume group "vg0" with active logical volumes? [y/n]: n
>   Volume group "vg0" not removed
> # vgremove -f vg0
>   Error locking on node rhel4u5-node1: Volume is busy on another node
>   Can't get exclusive access to volume "lv0"
> # vgremove vg0
> Do you really want to remove volume group "vg0" with active logical volumes? [y/n]: y
> Do you really want to remove active logical volume "lv0"? [y/n]: y
>   Error locking on node rhel4u5-node1: Volume is busy on another node
>   Can't get exclusive access to volume "lv0"

Updated patch attached that fixes the above case.  Now we can remove LVs
that may be active on other nodes in the cluster:
[root at rhel4u5-node1 LVM2]# ./tools/lvm vgremove vg0
Do you really want to remove volume group "vg0" containing 1 logical
volumes? [y/n]: y
  Error locking on node rhel4u5-node1: Volume is busy on another node
Logical volume "lv0" is active on other cluster nodes.  Really remove?
[y/n]: y
  Logical volume "lv0" successfully removed
  Volume group "vg0" successfully removed

The new check seems ok even when another node has the LV open (e.g.
mounted) - the remove just fails at the deactivate_lv() call for the
node(s) that have it open:
[root at rhel4u5-node1 LVM2]# ./tools/lvm vgremove vg0
Do you really want to remove volume group "vg0" containing 1 logical
volumes? [y/n]: y
  Error locking on node rhel4u5-node1: Volume is busy on another node
Logical volume "lv0" is active on other cluster nodes.  Really remove?
[y/n]: y
  Error locking on node rhel4u5-node3: LV vg0/lv0 in use: not
deactivating
  Unable to deactivate logical volume "lv0"


Also cleaned up the first message "Do you really want to remove..." -
got rid of "active" word (at that point, we don't know any LVs are
active) and printed the number of LVs in the VG.


-------------- next part --------------
A non-text attachment was scrubbed...
Name: vgremove-f-current.patch
Type: text/x-patch
Size: 5824 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20070824/eb3a4079/attachment.bin>
