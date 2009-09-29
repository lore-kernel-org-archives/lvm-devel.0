From: Mike Snitzer <snitzer@redhat.com>
Date: Tue, 29 Sep 2009 18:09:03 -0400
Subject: Re: [PATCH 2/4] Eliminate _check_lv_status's 'name' argument
In-Reply-To: <1254237777-30501-3-git-send-email-snitzer@redhat.com>
References: <1254237777-30501-1-git-send-email-snitzer@redhat.com>
	<1254237777-30501-3-git-send-email-snitzer@redhat.com>
Message-ID: <20090929220903.GA2666@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Tue, Sep 29 2009 at 11:22am -0400,
Mike Snitzer <snitzer@redhat.com> wrote:

> _check_lv_status's 'name' argument sometimes contains a name of a VG and
> sometimes name of an LV, so using it in generic code would be dangerous.
> 'name' was never used for anything other than progress_display.
> 
> The next patch will properly split out context specific
> progress_display.

Updated patch is available here:
http://people.redhat.com/msnitzer/patches/snapshot-merge/lvm2/LVM2-2.02.54/lvm-poll-drop-argument-name-in-_check_lv_status.patch


