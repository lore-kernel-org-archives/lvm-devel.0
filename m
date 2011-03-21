From: Milan Broz <mbroz@redhat.com>
Date: Mon, 21 Mar 2011 16:30:29 +0100
Subject: [PATCH 1/3] Require stable libudev version and remove defines used for former unstable versions
In-Reply-To: <4D87636C.7090209@redhat.com>
References: <4D87636C.7090209@redhat.com>
Message-ID: <4D876F15.7050706@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 03/21/2011 03:40 PM, Peter Rajnoha wrote:
> Libudev got stabilized in v143. Require that version directly in configure and
> remove "define LIBUDEV_I_KNOW_THE_API_IS_SUBJECT_TO_CHANGE" that was needed
> for unstable versions of libudev.

ack.

> -		     [UDEV_PC="libudev"; UDEV_LIBS="-ludev"],
> -		     [AC_MSG_ERROR([bailing out... libudev library is required])])
> +	PKG_CHECK_MODULES(UDEV, libudev >= 143, [UDEV_PC="libudev"],
> +			  [AC_MSG_ERROR([bailing out... libudev library version >= 143 is required])])

One day, someone, somewhere, somehow .... could fix static build here.. (UDEV_LIBS)

Milan


