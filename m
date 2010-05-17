From: Takahiro Yasui <tyasui@redhat.com>
Date: Mon, 17 May 2010 19:01:45 -0400
Subject: [PATCH] handle transient errors in lvconvert --repair
In-Reply-To: <4BEDD432.4010800@redhat.com>
References: <87y6g99bbg.fsf@twilight.int.mornfall.net.>	<87pr1kai2k.fsf@twilight.int.mornfall.net.>	<87y6fxos3x.fsf@twilight.int.mornfall.net.>
	<4BEDD432.4010800@redhat.com>
Message-ID: <4BF1CAD9.1050005@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi Petr,

On 05/14/10 18:52, Takahiro Yasui wrote:
>> I have rebased the patch against current CVS. Also, I have added a guard
>> to _mirrored_transient_status to ensure that we alloca() only very
>> modest (and, more importantly, bounded) amount of memory.
> 
> This patch is just a rebase against current CVS, so it doesn't support
> mirrored log, yet. Do you have a plan to support mirrored log?
> 
> I also tested this patch for a lvm mirror with core/disk log. When
> a mirror log failed, the mirror log was removed from a mirror volume,
> but a log voluem is not removed from its volume group. This always
> happens both on a transient and persistent error.

This issue seems related to this part of your patch.

@@ -1139,6 +1163,8 @@ static int _lvconvert_mirrors_repair(str
...
-	/*
-	 * Remove all failed_pvs
-	 */
-	if (!_lvconvert_mirrors_aux(cmd, lv, lp, failed_pvs,
-				    lp->mirrors, new_log_count))
-		return 0;
+	if (failed_mirrors) {
+		if (!lv_remove_mirrors(cmd, lv, failed_mirrors, new_log_count,
+				       _is_partial_lv, NULL, 0))
+			return 0;
+
+		if (!_reload_lv(cmd, lv))
+			return 0;
+	}

When I removed this modification, a log volume was removed as expected.
And also other my test cases also passed.

I hope this information would be helpful.

Thanks,
Taka


