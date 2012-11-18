From: Mike Hommey <mh@glandium.org>
Date: Sun, 18 Nov 2012 16:52:59 +0100
Subject: LVM Encryption
Message-ID: <20121118155259.GA9513@glandium.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

The usual setup for full disk encryption on Linux systems is LVM over
LUKS. This kind of setup however doesn't allow for easy migration from
non-encrypted systems, and lacks some flexibility.

Has embedding some encryption system into LVM itself ever been
considered, and if it has, why has it been dismissed? If not, would it
be something the LVM developers would be interested in pursuing?

Cheers,

Mike


