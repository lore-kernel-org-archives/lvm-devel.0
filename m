From: Mikulas Patocka <mpatocka@redhat.com>
Date: Tue, 19 May 2009 16:43:12 -0400 (EDT)
Subject: LVM command-line interface for shared snapshots
In-Reply-To: <0ab001c9d809$89ddce90$9d996bb0$@com>
References: <20090514212943.GA25445@redhat.com>
	<Pine.LNX.4.64.0905181136510.22422@hs20-bc2-1.build.redhat.com>
	<095d01c9d7f2$4295a290$c7c0e7b0$@com>
	<20090518222822.GA1319@redhat.com>
	<0ab001c9d809$89ddce90$9d996bb0$@com>
Message-ID: <Pine.LNX.4.64.0905191636010.19127@hs20-bc2-1.build.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi

Here I'm submitting the proposed interface.

The code is at 
http://people.redhat.com/mpatocka/patches/userspace/new-snapshots/preview/ 
--- it is in a very early stage of development, it can currently only 
create the shared store, activate/deactivate it and delete it. It can't 
create or attach the individual snapshots.

BTW. regarding the snapshot merging, the man page for merging non-shared 
snapshots is here:
http://people.redhat.com/mpatocka/patches/userspace/new-snapshots/preview/lvm-merge-man-lvconvert.patch

Mikulas

---

lvcreate -s --sharedstore mikulas -L 192M -c 64k vg1/lv1
lvcreate -s --sharedstore fujita-daniel -L 192M -c 16k vg1/lv1
--- creates shared store vg1/lv1-shared with specified size and chunk size

lvcreate -s -n snapshot_name vg1/lv1
--- creates snapshot in the shared store

The last two command could be combined into one that performs both actions:
lvcreate -s --sharedstore mikulas -L 192M -n snapshot_name vg1/lv1

lvresize -L 256M vg1/lv1-shared
--- resize the shared snapshot store

lvresize -L 1G vg1/snapshot_name
--- resize the filesystem in the snapshot (seems more reasonable than resizing
the common storage)

lvremove vg1/snapshot_name
--- delete the snapshot in the snapshot store (but leave the snapshot
store there)

lvremove vg1/lv1-shared
--- delete the shared store with all the snapshots

The lvs command output should look something like this:
  LV         VG   Attr   LSize   Origin Snap%  Move Log Copy%  Convert
  lv1        vg1  owi-a-  56,00M
  lv1-shared vg1  swi---  12,00M lv1     12%
  snapshot   vg1  swi-a-         lv1
  snapshot2  vg1  swi-a-         lv1
  snapshot3  vg1  swi-a-         lv1

--- it contains the line for the shared volume (so that the admin knows
that there is a shared volume), and will contain each separate line for
each snapshot.


Reasons:

Suppose that there is some web-based or gui interface for management of
virtual machines. The interface has buttons [CREATE VM], [DELETE VM] and
[RESIZE STORE].

The code for the buttons should be same for the situations when there
are zero machines or non-zero machines. So I presume that the shared
store will be create when the package is installed (with command
lvcreate -s --sharedstore mikulas -L 1G vg1/lv_vm)

Then, [CREATE VM] button will execute lvcreate -s -n vm_name vg1/lv_vm
[DELETE VM] will execute lvremove vg1/vm_name
[RESIZE STORE] will execute lvresize -L 2G vg1/lv_vm-shared

Note that the [RESIZE STORE] button must work even in situation when
there are zero virtual machines, that's why we need a separate logical
volume vg1/lv_vm-shared

For admin's convenience (so that he doesn't have to type two commands),
we will implement a command that creates both the store and the first
snapshot:
lvcreate -s --sharedstore mikulas -L 192M -n snapshot_name vg1/lv1



Open questions:

* Should lvremove vg1/snapshot_name remove the whole shared store if the
last snapshot was removed?

For the needs of scripts, it definitely must not. But for admin's
convenience? Add a parameter, like "lvremove -r vg1/snapshot" that will
remove the whole store if this is the last snapshot? Say what you think
about it.


* Regarding --- what would happen if someone specifies "-L sizeM" and
there's already shared store allocated?

Solution 1: ignore the -L parameter. Old scripts (written before
snapshot shared store) will continue to run, the admin just must
estimate the total size and create a shared volume of that size prior to
running the script.

Solution 2: increase the shared-store size by the parameter of -L. In
order to prevent the store from growing forever, we store the increased
size in the snapshot's metadata. When we delete the snapshot, we can
either decrease size of the store (when it'll be implemented ... it
isn't). Or, if we can't decrease the size, we can add the size to the
"credit" variable of the shared store. When further snapshots are
created, their size is subtracted from the "credit" and the shared store
is extended only when the "credit" reches zero.

Initialize shared_store:
shared_store->credit = 0;

Create a snapshot with size L:
snapshot->size = L;
if (L <= shared_shore->credit)
	shared_store->credit -= L;
else {
	extend shared store by (L - shared_store->credit)
	shared_store->credit = 0;
}

Delete a snapshot:
shared_store->credit += snapshot

"credit" and "size" variables are stored in metadata.

This is complicated, but it will keep old scripts written without
shared-store consideration running, reallocating the store as needed and
not overflowing it. The downside is that it is complicated and
non-intuitive, the upside is that all these complications will happen
ONLY if someone specifies the "L" parameter when creating a snapshot in
a shared store, all the other commands will be unaffected by this.

What do you think? Is solution 2 unreasonable overkill? Or not? Would
solution 1 would be sufficient?


