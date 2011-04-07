From: Jonathan Brassow <jbrassow@redhat.com>
Date: Thu, 7 Apr 2011 10:20:45 -0500
Subject: LVM2 lib/metadata/lv_manip.c lib/metadata/meta ...
In-Reply-To: <4D9DA98D.2000007@redhat.com>
References: <20110406213222.10912.qmail@sourceware.org>
	<4D9DA98D.2000007@redhat.com>
Message-ID: <7BF6E37A-25E5-4F8A-AC90-461D9AE26EF8@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


On Apr 7, 2011, at 7:09 AM, Zdenek Kabelac wrote:

>> +
>> +	dm_pool_free(lv->vg->cmd->mem, img_name);
> 
> 
> Aren't you experiencing random crashes with this  dm_pool_free() ?
> It removes also all objects allocated past this img_name.
> (Also I think there is already an internal function for building such names)

No crashes so far... I haven't run into that while running through the test suite or my by-hand tests.  Why would I expect that kind of behavior?

Also, do you know what the name of the internal function would be to replace my 'alloc, fill with template name, create empty lv's, free' sequence?

 brassow


