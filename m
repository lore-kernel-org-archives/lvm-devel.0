From: Peter Rajnoha <prajnoha@redhat.com>
Date: Thu, 25 Nov 2010 14:45:33 +0100
Subject: [PATCH 01/11] Add mda_slots field for PV info in the cache.
In-Reply-To: <4CEE6723.4020301@redhat.com>
References: <1290115945-27419-1-git-send-email-prajnoha@redhat.com>	<1290115945-27419-2-git-send-email-prajnoha@redhat.com>	<4CEE6180.6000706@redhat.com>
	<4CEE6723.4020301@redhat.com>
Message-ID: <4CEE687D.3090309@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 11/25/2010 02:39 PM +0100, Peter Rajnoha wrote:
> Of course, I can avoid using the cache this way, but that would mean far more
> changes to be done (for this interface to work). At least, it would mean consolidating
> the use of "format instance" and change the structure and its use throughout the
> code.

..I'd like to avoid making another copy of the cache. It's not about performance right
now, but it's more about keeping the code readable - having N copies of the same structures
around the code will bring confusion and bugs...

Peter


