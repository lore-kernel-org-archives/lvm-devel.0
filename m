From: Petr Rockai <prockai@redhat.com>
Date: Wed, 03 Mar 2010 14:55:24 +0100
Subject: [PATCH 0/9] configure update
In-Reply-To: <cover.1267529065.git.zkabelac@redhat.com> (Zdenek Kabelac's
	message of "Tue, 2 Mar 2010 13:07:18 +0100")
References: <cover.1267529065.git.zkabelac@redhat.com>
Message-ID: <87k4ttpl0z.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Zdenek Kabelac <zkabelac@redhat.com> writes:

> This patchset tries to mainly address linking problems.
> First few patches are rather cosmetic cleanups.
>
> Interestings patches starts with: Readline linking update.
>
> With this patchset libpthread and libselinux are linked only
> to object files which really needs this library.
> Tested it on Fedora & Debian distribution.

Overall, looks reasonably OK to me. Could certainly benefit from further
testing though.

Reviewed-By: Petr Rockai <prockai@redhat.com>

Yours,
   Petr.


