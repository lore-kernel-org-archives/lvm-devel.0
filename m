From: Peter Rajnoha <prajnoha@redhat.com>
Date: Mon, 21 Mar 2011 16:17:35 +0100
Subject: [PATCH 1/3] Require stable libudev version and remove defines used for former unstable versions
In-Reply-To: <4D87636C.7090209@redhat.com>
References: <4D87636C.7090209@redhat.com>
Message-ID: <4D876C0F.40904@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 03/21/2011 03:40 PM +0100, Peter Rajnoha wrote:
> +	PKG_CHECK_MODULES(UDEV, libudev >= 143, [UDEV_PC="libudev"],
> +			  [AC_MSG_ERROR([bailing out... libudev library version >= 143 is required])])

Well, I'd probably even leave the AC_MSG_ERROR out, so nice and detailed pkgconfig
errors are printed by default.

Peter


