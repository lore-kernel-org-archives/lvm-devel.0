From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu, 11 Apr 2019 13:21:12 +0200
Subject: Aborting. LV mythinpool_tmeta is now incomplete
In-Reply-To: <CAKM4Aex11MbzzGrWE=aYF+KM+_o3cOrs6N2n_T5+tSpuu7J=5Q@mail.gmail.com>
References: <CAKM4AewbcVR1x0cK8hWLCRxb1BzDd-F+WeK6ObUmB35N1HTqOA@mail.gmail.com>
	<CAKM4Aex11MbzzGrWE=aYF+KM+_o3cOrs6N2n_T5+tSpuu7J=5Q@mail.gmail.com>
Message-ID: <9c0fe4b3-24cb-837c-f8fa-c5b89c5665a4@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 11. 04. 19 v 12:01 Eric Ren napsal(a):
> Hi,
> 
> Another error message is:
> 
> "Failed to suspend thin snapshot origin?..."
> 
> which is in?_lv_create_an_lv():
> 
> ```
> 7829? ? ? ? ?} else if (lv_is_thin_volume(lv)) {
> 7830? ? ? ? ? ? ? ? ?/* For snapshot, suspend active thin origin first */
...

> is active */
> 7843? ? ? ? ? ? ? ? ? ? ? ? ?if (!update_pool_lv(pool_lv, 0)) {
> 7844? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ?stack;
> 7845? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ?goto revert_new_lv;
> 7846? ? ? ? ? ? ? ? ? ? ? ? ?}
> ```
> 
> I don't understand why we need to?suspend_lv_origin() and?resume_lv_origin() 
> in line?
> 
> And, what reasons might cause this errors?


Hi

When you take any snapshot (thin or thick) the origin LV is suspend with 
fsfreeze operation - so the snapshot is takes with filesystem in 'consistent' 
state.

Otherwise without this - you may end-up with fs junk in your device - as the 
metadata of the filesystem might have stated in page-cache - and no fsck 
utility would be able to figure out what should be correct state of 'fs' 
without losing various amount of data in this operation.


Regards

Zdenek


