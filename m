From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue, 27 Sep 2011 17:44:49 +0200
Subject: [PATCH v3 12/18] lvresize: Specify --resize-fs-only when going to use fsadm resize
In-Reply-To: <1317130971-24173-13-git-send-email-lczerner@redhat.com>
References: <1317130971-24173-1-git-send-email-lczerner@redhat.com>
	<1317130971-24173-13-git-send-email-lczerner@redhat.com>
Message-ID: <4E81EF71.4070906@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 27.9.2011 15:42, Lukas Czerner napsal(a):
> When lvresize is calling fsadm to resize the file system, originally
> it was the default action. However now fsadm support much more
> features and it is doing the lvresize by itself. Luckily there is
> still a way to tell fsadm to resize only the file system ane leave
> the rest up to the lvresize - provide "--resize-fs-only" argument.
> 
> This commit adds "--resize-fs-only" argument when we are going to
> use fsadm to resize the fs from within the lvresize.


There is a big reason to call lvresize for this operation - it's the cluster
atomicity, so the resize operation (while using lvm tools) provide consistent
results - this breaks it - so NACK for now.

Zdenek


