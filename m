From: Peter Rajnoha <prajnoha@redhat.com>
Date: Mon, 25 Jun 2012 12:39:39 +0200
Subject: master - dev-io: open device read-only to obtain readahead value
In-Reply-To: <4FE83CF9.9010805@redhat.com>
References: <20120625095647.C465B1706@lists.fedorahosted.org>
	<4FE83CF9.9010805@redhat.com>
Message-ID: <4FE83FEB.4050507@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 06/25/2012 12:27 PM, Zdenek Kabelac wrote:
> Dne 25.6.2012 11:56, Peter Rajnoha napsal(a):
>>
>> dev-io: open device read-only to obtain readahead value
>>
> Which should be further fixed to use sysfs improved libdm method.
> 

Indeed. Though the libdm fn needs refactoring then to take all
block devs, not just DM ones as current dm_task_get_read_ahead
is bound to a "DM task"... a new fn would be required in libdm
to do that as a matter of fact.

Peter


