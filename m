From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue, 27 Oct 2015 11:53:22 +0100
Subject: [PATCH] pvcreate: don't support unpartitioned DASD devices with CDL formatted
In-Reply-To: <1444633751-10796-1-git-send-email-lzhong@suse.com>
References: <1444633751-10796-1-git-send-email-lzhong@suse.com>
Message-ID: <562F57A2.6020005@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 12.10.2015 v 09:09 Lidong Zhong napsal(a):
> The former patch(dab3ebce4c7) is a little bit strict. For example, it is
> OK to create PV on unpartitioned DASD devices with LDL formatted. So
> after lvm version containing the patch, LVs created on those devices
> could not be found.
>


Thanks for code, upstreamed here:

https://www.redhat.com/archives/lvm-devel/2015-October/msg00164.html

Regards

Zdenek


