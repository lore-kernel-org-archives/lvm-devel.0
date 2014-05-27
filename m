From: Peter Rajnoha <prajnoha@redhat.com>
Date: Tue, 27 May 2014 09:00:50 +0200
Subject: master - dmsetup: add warning
In-Reply-To: <20140526213220.BF35F60DC8@fedorahosted.org>
References: <20140526213220.BF35F60DC8@fedorahosted.org>
Message-ID: <53843822.1080102@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 05/26/2014 11:32 PM, Zdenek Kabelac wrote:
> Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3cb2658fb7ff0bba45e66e79bce8812c819dff52
> Commit:        3cb2658fb7ff0bba45e66e79bce8812c819dff52
> Parent:        6e9105c7bb7f4a1beb34579303670e4510c7d2e6
> Author:        Zdenek Kabelac <zkabelac@redhat.com>
> AuthorDate:    Mon May 26 22:51:04 2014 +0200
> Committer:     Zdenek Kabelac <zkabelac@redhat.com>
> CommitterDate: Mon May 26 22:56:30 2014 +0200
> 
> dmsetup: add warning
> 
> Warn when --udevcookie/DM_UDEV_COOKIE is used with 'dmsetup remove --force'.
> 
> When command is doing multiple ioctl operations on a single device,
> it may invoke udev activity, that is colliding with further ioctl commands.
> The result of such operation becomes unpredictable.
> Use of --retry could partially help...

We could add proper flags to skip all the scanning in udev in case we're
resuming the mapping with error target for the "remove --force"...

-- 
Peter


