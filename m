From: Takahiro Yasui <tyasui@redhat.com>
Date: Wed, 19 May 2010 20:49:47 -0400
Subject: [PATCH] handle transient errors in lvconvert --repair
In-Reply-To: <874oi34ubd.fsf@twilight.int.mornfall.net.>
References: <87y6g99bbg.fsf@twilight.int.mornfall.net.>	<87pr1kai2k.fsf@twilight.int.mornfall.net.>	<87y6fxos3x.fsf@twilight.int.mornfall.net.>	<4BEDD432.4010800@redhat.com>
	<4BF1CAD9.1050005@redhat.com>	<87ljbg3xkt.fsf@twilight.int.mornfall.net.>	<4BF3FE5C.8070906@redhat.com>
	<874oi34ubd.fsf@twilight.int.mornfall.net.>
Message-ID: <4BF4872B.5060204@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi Petr,

On 05/19/10 14:31, Petr Rockai wrote:
> The attached patch is on top of the previous one -- it should apply
> cleanly on top of current CVS + the lvconvert-repair-transient.diff I
> have sent previously. It also fixes a bug in messages, where it would
> claim that it failed to replace things even if it never tried to in the
> first place.
> 
> Please test and let me know if you run into any other issues.

I tested your two patches and all my test cases for 'disk' log
passed. As for 'mirrored' log, we need to check the state for
log_lv. Here is the sample code.

_lvconvert_mirrors_repair()
...
        lv_check_transient(lv); /* TODO check this in lib for all commands? */

-       if (!(lv->status & PARTIAL_LV)) {
+       log_lv = first_seg(lv)->log_lv;
+       if (log_lv && log_lv->status & MIRRORED)
+               lv_check_transient(log_lv);
+
+       if (!(lv->status & PARTIAL_LV) && !log_lv &&
+           !(log_lv->status & PARTIAL_LV)) {
...
        new_log_count = old_log_count;
-       log_lv = first_seg(lv)->log_lv;
        if (log_lv) {

Thanks,
Taka


