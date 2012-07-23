From: M. Mohan Kumar <mohan@in.ibm.com>
Date: Mon, 23 Jul 2012 16:34:29 +0530
Subject: lvm_vg_list_lvs API
Message-ID: <87y5mabuwy.fsf@in.ibm.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Hello,

I am using lvm_vg_list_lvs API to enumerate the list of LVs in a given
VG. When I create a snapshot of LV, I am seeing in addition to snapshot
LV, there is another lv with name "snapshot0" also returned by this
API. Is it expected behaviour?

Is there any way I can differentiate between this snapshot0 and created
LV snapshot?

For example, I have a LV 'l' initially and then created snapshot of that
with name 'cccc'. But now lvm_vg_list_lvs API returns 3 LVs like this:

 l:size 4194304
 cccc:size 4194304
 snapshot0:size 4194304


But lvdisplay displays only 'l' and 'cccc' in the output.

How do I filter this 'snapshot0' from lvm_vg_list_lvs?


