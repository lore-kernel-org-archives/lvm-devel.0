From: Petr Rockai <prockai@redhat.com>
Date: Tue, 27 Jul 2010 21:06:31 +0200
Subject: [PATCH] Handle a failure of all mirror devices but one mirror leg
In-Reply-To: <5C30BE7ED8B03E448B2E104602D4848A5922886542@USINDEVS02.corp.hds.com>
	(Takahiro Yasui's message of "Mon, 19 Jul 2010 18:09:43 -0400")
References: <5C30BE7ED8B03E448B2E104602D4848A5922886542@USINDEVS02.corp.hds.com>
Message-ID: <87vd80922w.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

Takahiro Yasui <takahiro.yasui@hds.com> writes:
> In addition, I added following three changes.
>
> - Removed tmp_orphan_lvs handling procedure
>   It seems that _delete_lv() can handle detached_log_lv properly
>   without adding mirror legs in mirrored log to tmp_orphan_lvs.
>   Therefore, I removed the procedure.
>
> - Removed vg_write()/vg_commit()
>   Metadata is saved by vg_write()/vg_commit() just after detached_log_lv
>   is handled. Therefore, I removed vg_write()/vg_commit().
>
> - With Jon's second patch, we think that we don't have to call
>   remove_mirror_log() in _lv_update_mirrored_log() because will be
>   handled remove_mirror_images() in _lvconvert_mirrors_repaire().
>
> Appreciate your reviews and comments.
for what it's worth, I like that the patch simplifies the spaghetti in
_remove_mirror_images and overall I don't see anything clearly wrong
about it. Nevertheless, I do think that the patch needs careful testing,
especially in cluster. (I have checked that the testsuite passes, but
unfortunately it doesn't have sufficient coverage of various failure
scenarios, especially with cluster...)

Yours,
   Petr.

Reviewed-By: Petr Rockai <prockai@redhat.com>


