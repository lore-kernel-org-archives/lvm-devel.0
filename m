From: malahal@us.ibm.com <malahal@us.ibm.com>
Date: Mon, 30 Nov 2009 02:32:09 -0800
Subject: [PATCH] Improve mirror DSO's failure logging
In-Reply-To: <4B0B0617.9010001@redhat.com>
References: <c107c082a3a5ab4f4a95.1258760198@localhost>
	<4B0B0617.9010001@redhat.com>
Message-ID: <20091130103209.GA8300@us.ibm.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Takahiro Yasui [tyasui at redhat.com] wrote:
> I'm afraid that only an error status of the device with the smallest index
> of the dev_status_str[] array will be reported. For example, if the status
> is "ARD," "r" will have a value, ME_READ_FAILURE. Then, a write failure
> event (ME_PRIMARY_WRITE_FAILURE and ME_SECONDARY_WRITE_FAILURE) won't be
> detected in process_event(). I think that "WRITE_FAILURE" events should
> have priority.

Thank you, Takahiro. Just posted a patch fixing the above issue. I used
them as flags to fix it. Let me know what you think.

See
http://permalink.gmane.org/gmane.linux.kernel.device-mapper.devel/10675
for details.

Thanks, Malahal.


