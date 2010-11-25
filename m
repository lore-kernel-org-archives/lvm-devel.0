From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri, 26 Nov 2010 00:12:43 +0100
Subject: [PATCH 02/29] Fix check for empty system_dir
In-Reply-To: <87vd3lmich.fsf@twilight.int.mornfall.net.>
References: <cover.1290682013.git.zkabelac@redhat.com>	<cover.1290682013.git.zkabelac@redhat.com>	<ced2653c100dd20c1ed531b6ce59ae14a7396b13.1290682013.git.zkabelac@redhat.com>
	<87vd3lmich.fsf@twilight.int.mornfall.net.>
Message-ID: <4CEEED6B.4050606@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 25.11.2010 18:19, Petr Rockai napsal(a):
> Zdenek Kabelac <zkabelac@redhat.com> writes:
> 
>> Fixing most probably a typo - I assume original intention has been
>> to check for zero length string.
> 
> In that case, please use !strlen(str), as that is much more readable.
> 

In this case I believe it's common practice not only in our source to check
the first char for '\0' when checking for empty string - so are we planning to
replace in other places in lvm code - then I'd propose probably some nice
macro  empty_string() or whatever name we could think of?


Zdenek


