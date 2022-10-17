From: Demi Marie Obenour <demi@invisiblethingslab.com>
Date: Mon, 17 Oct 2022 11:16:22 -0400
Subject: [linux-lvm] LVM2 : performance drop even after deleting the snapshot
In-Reply-To: <2e6bad30-2ebf-4162-b62d-092c3ad14003@gmail.com>
References: <PUZP153MB075126926388815B6F9E1258AC229@PUZP153MB0751.APCP153.PROD.OUTLOOK.COM>
 <PUZP153MB07512B1B646868F0F8F1D205AC259@PUZP153MB0751.APCP153.PROD.OUTLOOK.COM>
 <CAAMCDefYPozC32AdCqw-c1nOZNiEK0j0pG7n+zcu_bRwTfCagg@mail.gmail.com>
 <2e6bad30-2ebf-4162-b62d-092c3ad14003@gmail.com>
Message-ID: <Y01xx0qpzYCXjDL/@itl-email>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Fri, Oct 14, 2022 at 10:28:28PM +0200, Roberto Fastec wrote:
> TIP and HINT
> forget SSDs with LVM unless of enterprise level 
> especially if you are going to use/implement the thin provisioning

As a user and developer of Qubes OS, this makes me nervous.  Qubes OS
uses LVM heavily in the default configuration, and is designed for
end-user systems.
-- 
Sincerely,
Demi Marie Obenour (she/her/hers)
Invisible Things Lab
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 833 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20221017/94f74bd8/attachment.sig>
