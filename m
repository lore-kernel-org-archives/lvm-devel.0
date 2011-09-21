From: Peter Rajnoha <prajnoha@redhat.com>
Date: Wed, 21 Sep 2011 13:23:13 +0200
Subject: [PATCH 4/7][retry remove] Add new "dm_device_has_holders" fn to libdm
In-Reply-To: <4E7890B2.9060409@redhat.com>
References: <4E788DA5.8010304@redhat.com> <4E7890B2.9060409@redhat.com>
Message-ID: <4E79C921.8070903@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 09/20/2011 03:10 PM +0100, Zdenek Kabelac wrote:
> Dne 20.9.2011 14:57, Peter Rajnoha napsal(a):
>> +	if (!(d = opendir(dir))) {
>> +		log_sys_error("opendir", dir);
>> +		return 0;
>> +	}
>> +
>> +	while ((dirent = readdir(d)))
>> +		if (strcmp(dirent->d_name, ".") && strcmp(dirent->d_name, ".."))
>> +			break;
> 
> Hmm since  readdir() may return -1 - this looks like error check is missing here

Well, this is a version of readdir that returns either NULL or a pointer to a dirent
structure - man 2 readdir vs. man 3 readdir (difference in POSIX compliance).

The POSIX version returns an error only if the DIR* stream descriptor is wrong, but
this one should be fine since we already check the error in opendir just before this
call. I think it's OK to do it this way.

Peter


