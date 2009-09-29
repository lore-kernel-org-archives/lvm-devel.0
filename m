From: Mike Snitzer <snitzer@redhat.com>
Date: Tue, 29 Sep 2009 18:09:43 -0400
Subject: Re: [PATCH 3/4] Define new periodic polling method: poll_progress
In-Reply-To: <1254237777-30501-4-git-send-email-snitzer@redhat.com>
References: <1254237777-30501-1-git-send-email-snitzer@redhat.com>
	<1254237777-30501-4-git-send-email-snitzer@redhat.com>
Message-ID: <20090929220943.GB2666@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Tue, Sep 29 2009 at 11:22am -0400,
Mike Snitzer <snitzer@redhat.com> wrote:

> Define new polling method poll_progress that is called periodically. The method
> can return:
> 0 --- error
> PROGRESS_TRY_AGAIN --- should be called again after specified interval
> PROGRESS_UPDATE_METADATA --- should call update_metadata method and continue
> 			     polling
> PROGRESS_FINISHED --- should call finish_copy and exit polling
> 
> The hard-coded mirror-specific code in polldaemon was moved to function
> poll_mirror_progress. The rest of the polldaemon is mirror-free so it can be
> used for merging snapshots as well.

Updated patch is available here:
http://people.redhat.com/msnitzer/patches/snapshot-merge/lvm2/LVM2-2.02.54/lvm-poll-progress-method.patch


