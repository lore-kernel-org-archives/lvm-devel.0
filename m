From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 16 Jun 2010 14:14:52 +0200
Subject: [PATCH] Allow use headers in C++.
In-Reply-To: <1276532407-15147-1-git-send-email-mbroz@redhat.com>
References: <1276532407-15147-1-git-send-email-mbroz@redhat.com>
Message-ID: <4C18C03C.7090904@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 14.6.2010 18:20, Milan Broz napsal(a):
> Remove C++ private keyword from header.
> Add extern C definition for libdevmapper and lvm2app.
> ---
>   libdm/libdevmapper.h |   13 ++++++++++---
>   libdm/libdm-report.c |    4 ++--
>   liblvm/lvm2app.h     |    6 ++++++
>   3 files changed, 18 insertions(+), 5 deletions(-)
>
> diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
> index 0b67a0f..7c72cf7 100644
> --- a/libdm/libdevmapper.h
> +++ b/libdm/libdevmapper.h
> @@ -1,6 +1,6 @@


Ack

When we do this for libdevmapper.h and lvm2app.h, then for consistency C++ 
externs should be applied to remaing user exported headers:

libdevmapper-event.h
lvm2cmd.h

Zdenek


