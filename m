From: Jonathan Brassow <jbrassow@redhat.com>
Date: Tue, 24 Nov 2009 09:36:53 -0600
Subject: [PATCH] Improve mirror DSO's failure logging
In-Reply-To: <4B0B0617.9010001@redhat.com>
References: <c107c082a3a5ab4f4a95.1258760198@localhost>
	<4B0B0617.9010001@redhat.com>
Message-ID: <DFD1FB5B-6254-43C4-A6AE-90858A44831B@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


On Nov 23, 2009, at 4:00 PM, Takahiro Yasui wrote:

> I'm afraid that only an error status of the device with the smallest  
> index
> of the dev_status_str[] array will be reported. For example, if the  
> status
> is "ARD," "r" will have a value, ME_READ_FAILURE. Then, a write  
> failure
> event (ME_PRIMARY_WRITE_FAILURE and ME_SECONDARY_WRITE_FAILURE)  
> won't be
> detected in process_event(). I think that "WRITE_FAILURE" events  
> should
> have priority.
>
> Thanks,
> Taka

Good catch Taka, I agree.  Otherwise, I welcome this patch.

  brassow


