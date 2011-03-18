From: Peter Rajnoha <prajnoha@redhat.com>
Date: Fri, 18 Mar 2011 13:10:45 +0100
Subject: [PATCH] Mitigate some warnings if running as non-root user.
In-Reply-To: <1300447937-8114-1-git-send-email-mbroz@redhat.com>
References: <1300447937-8114-1-git-send-email-mbroz@redhat.com>
Message-ID: <4D834BC5.4030803@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 03/18/2011 12:32 PM +0100, Milan Broz wrote:
> See https://bugzilla.redhat.com/show_bug.cgi?id=620571
> 
> This patch fixes two things:
> 1) Removes eror message from device_is_usable() which has no
> information value anyway (real warning is printed inside it).
> 
> 2) it fixes device-mapper initialization, if we support
> core dm module autoload and device node is present, it should
> fail early and not try recreate existing and correct node.
> (non-root == permission denied here)

Yes, we need to fix this! The patch is clear, runs fine. Ack.

Peter


