From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue, 21 Dec 2010 16:04:23 +0100
Subject: [PATCH 25/29] Check for unlink result
In-Reply-To: <20101129215111.GO29380@agk-dp.fab.redhat.com>
References: <cover.1290682013.git.zkabelac@redhat.com>	<6022829a3292ffcc95debee81bda60e0522698e2.1290682013.git.zkabelac@redhat.com>
	<20101129215111.GO29380@agk-dp.fab.redhat.com>
Message-ID: <4D10C1F7.9090506@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 29.11.2010 22:51, Alasdair G Kergon napsal(a):
> On Thu, Nov 25, 2010 at 11:55:29AM +0100, Zdenek Kabelac wrote:
>> +	if (unlink(path))
>> +		log_debug("Unlink %s failed: %s", path, strerror(errno));
> 
> log_sys_debug ?
> 


At this place it's valid the file in the moment of unlink doesn't exist.
There is no explicit test for existence of backup file - so I've used only
debug to print reason for failure at least in debug log.
(Assuming 'Let this fail silently.' has this meaning)

Zdenek


