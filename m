From: Milan Broz <mbroz@redhat.com>
Date: Mon, 19 Nov 2012 13:48:50 +0100
Subject: LVM Encryption
In-Reply-To: <20121118155259.GA9513@glandium.org>
References: <20121118155259.GA9513@glandium.org>
Message-ID: <50AA2AB2.1090109@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 11/18/2012 04:52 PM, Mike Hommey wrote:
> The usual setup for full disk encryption on Linux systems is LVM over
> LUKS. This kind of setup however doesn't allow for easy migration from
> non-encrypted systems, and lacks some flexibility.

It is possible, but it is very complicated.
For some crazy example see
http://asalor.blogspot.cz/2012/08/re-encryption-of-luks-device-cryptsetup.html
 
> Has embedding some encryption system into LVM itself ever been
> considered, and if it has, why has it been dismissed? If not, would it
> be something the LVM developers would be interested in pursuing?

It was considered, I wrote even some patches (see list archive, nobody replied,
http://www.redhat.com/archives/lvm-devel/2009-January/thread.html#00082)
and then I abandoned this completely.

So, it is possible, but I think it is not worth to do it, there are
other ways to handle it.

Of course, if there is enough requests, I am sure it will be reconsidered,
but I spent a lot of time to try to do it and my final decision was that
maintaining it separately is better.

Just some reasons (not there is no clear blocker, just complications, some
problems shifted since patches were posted also):

- as you said, many users prefer LVM over LUKS (so LVM metadata is encrypted)
(it would be better to have some tool which automate even this config)

- I think it is best to have encryption as separated layer. This doesn't
limit you regarding to used metadata type (you can use Truecrypt, you can use
plain dmcrypt (no header) or LUKS with detached header.

- problems with vgcfgrestore (you need to maintain history of LUKS metadata also
and safely wipe headers. This is itself potential security problem.

(Example: imagine you restored lvm metadata and old LUKS header remains somewhere
on the disk - in old LV start area. If an attacker (or former employee etc) have
old password to this forgotten LUKS copy, he can still decrypt LV even if you have
changed password to new LUKS header. If lvm integrates encryption handling it
should solve these problems by design.)

- problems with internal caching of keys/passphrases inside lvm code
(it does device-mapper reloads and cannot ask user every time e.g. inside pvmove)

This means that even if you separate encryption handling (in patches to libcryptsetup
library) you still need to audit lvm (this is problem mainly for certifications).
(And yes, kernel dmcrypt should use kernel keyring for this.)

- patches were very invasive and with current raid and thin provision the test
matrix multiplies, AFAIK there are simply not enough resources and the priority
were elsewhere (better udev integration, raid, thin provisioning)

But note, I am no longer in lvm devel team, so this is just my opinion
(as cryptsetup/luks maintainer).

So what's the solution for now?

I think that it is simpler to use fsadm approach (similar to resize filesystem)
with very similar results. Someone can write patches for automatic resize,
it is trivial (cryptsetup reload handles LUKS device resize online).

Also you can use cryptsetup-reencrypt in combination with lvresize for offline
encryption addition to LV (despite it is not so trivial as just use one lvm command).

For adding encryption - basically you just need to add one (4MiB) extent
to LV (or reduce fs by one extent) to create space for LUKS header and then
with LV unmounted (offline) run cryptsetup-reencrypt (it uses in-file temporary
metadata during reencryption).

Milan


