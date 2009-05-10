From: Petr Rockai <prockai@redhat.com>
Date: Sun, 10 May 2009 20:41:32 +0200
Subject: [PATCH 3/7] Remove snapshot_count from VG and use function instead.
In-Reply-To: <a015c94d4f5d34699e100b182f539812543b883e.1241620083.git.mbroz@redhat.com>
	(Milan Broz's message of "Wed, 6 May 2009 16:43:00 +0200")
References: <cover.1241620083.git.mbroz@redhat.com>
	<cover.1241620083.git.mbroz@redhat.com>
	<a015c94d4f5d34699e100b182f539812543b883e.1241620083.git.mbroz@redhat.com>
Message-ID: <87iqk8u7fn.fsf@eriador.mornfall.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Patch looks good. Good to get rid of redundant counter, which is prone to
getting out of sync. I would, however, propose to rename "snapshot_lvs_in_vg"
to "vg_snapshot_lv_count" -- we already have "vg_missing_pv_count" as a
precedent for that naming scheme.

Yours,
   Petr.

PS: I would welcome a similar approach to removing lv_count as well (and other
redundant counters), since the counting function's implementation clearly
defines what gets counted in the given counter (vg_lv_count, say), *and* it
never gets out of sync. In other words, I believe this approach is much more
transparent, albeit a little less efficient -- however, I don't believe such
counting function is going to show up on any profile of any LVM2 command
whatsoever.

-- 
Peter Rockai | me()mornfall!net | prockai()redhat!com
 http://blog.mornfall.net | http://web.mornfall.net

"In My Egotistical Opinion, most people's C programs should be
 indented six feet downward and covered with dirt."
     -- Blair P. Houghton on the subject of C program indentation


