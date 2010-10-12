From: Petr Rockai <prockai@redhat.com>
Date: Tue, 12 Oct 2010 13:05:56 +0200
Subject: [PATCH 11/14] Add lvm_vg_get_property() generic vg property function.
In-Reply-To: <4CB41EF8.9010706@redhat.com> (Zdenek Kabelac's message of "Tue, 
	12 Oct 2010 10:40:24 +0200")
References: <1286810078-25769-1-git-send-email-dwysocha@redhat.com>
	<1286810078-25769-12-git-send-email-dwysocha@redhat.com>
	<4CB41EF8.9010706@redhat.com>
Message-ID: <877hhnwu0b.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Zdenek Kabelac <zkabelac@redhat.com> writes:
>> +	struct lvm_property_type prop;
>> +
>> +	strncpy(prop.id, name, LVM_PROPERTY_NAME_LEN);
>
> Hmmm why doing a copy here instead of passing/assigning  'name' ptr somewhere?

Because lvm_property_type says: char id[LVM_PROPERTY_NAME_LEN];

Yours,
   Petr.


