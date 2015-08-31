From: Liuhua Wang <lwang@suse.com>
Date: Mon, 31 Aug 2015 02:39:32 -0600
Subject: [PATCH] libdm-iface: not output error message inside retry loops
In-Reply-To: <55E04B67.3060003@redhat.com>
References: <1440664241-6149-1-git-send-email-lwang@suse.com>
	<55DEFB92.5020106@redhat.com>
	<55E03ED2020000A000019F1D@relay2.provo.novell.com>
	<55E034E8.3010908@redhat.com>
	<55E0D18A020000A00004DDE2@relay2.provo.novell.com>
	<55E04B67.3060003@redhat.com>
Message-ID: <55E48344020000A00001A162@relay2.provo.novell.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi Zdenek,

>>> On 8/28/2015 at 07:52 PM, in message <55E04B67.3060003@redhat.com>, Zdenek
Kabelac <zkabelac@redhat.com> wrote: 
> Dne 28.8.2015 v 13:24 Liuhua Wang napsal(a):
> >
> > Thanks for your reply.
> >
> >>> Common scenario:
> >>>
> >>> The major reason for retry is 'unpredictable'  udev event processing
> >>> i.e. you run  'umount' -> fires watch-rule -> lvremove  could have failed -
> >>> retry fixes this problem.
> >>
> >>>    We first found this problem when we were testing lvcreate-usage.sh 
> included in
> >>>    lvm2-2.02.120 package. The case always failed due to the following 
> message:
> >>>     device-mapper: remove ioctl on (253:6) failed: Device or resource busy
> >>>    [ 0:01]   Node @TESTDIR@/dev/mapper/@PREFIX at vg-LV2-cow was not removed by 
> udev. Falling >>back to direct node removal.
> >
> >> Looks like udev issue.
> > You mean udev cookie related problem? Because I see udev cookie add and 
> remove
> > a little weird.
> >
> 
> So the question #1 -  are you using upstream lvm2 udev rules ?
> (matching with install package)
> 
> Are there any modification made to upsteam lvm2 udev rules?
> (Debian is usually having problems with those)
> 
> The rules are quite complex and any 'touch 'to them should be consulted with 
> 
> upstream authors.
Yes, udev rules have been modified a little, but even I replace them all with
upstream rules and reloaded, still has the issue.
 
> Could you create / remove snapshots without any problems.
> 
> I guess you should probably post failing logs for better diagnostic.

I attached my test log.

# lvcreate -s -L20M -nsnap vg/lv
  Logical volume "snap" created.

# lsblk 
NAME          MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
[...]
loop1           7:1    0   50M  0 loop 
??vg-lv-real  253:1    0   32M  0 lvm  
  ??vg-lv     253:0    0   32M  0 lvm  
  ??vg-snap   253:3    0   32M  0 lvm  
loop2           7:2    0   50M  0 loop 
??vg-snap-cow 253:2    0   20M  0 lvm  
  ??vg-snap   253:3    0   32M  0 lvm  

 # lvremove -ff vg/snap -vvvvv >lvremove-snap-failed.log 2>&1

Please see the detailed log attatched.
Thank you very much.

Regards,
Liuhua
-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvremove-snap-failed.log
Type: application/octet-stream
Size: 61887 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20150831/0af6c74f/attachment.obj>
