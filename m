Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=170.10.129.124
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793299544;
	b=HxOPJhyzpluoswQEuz5BRaBpxQs1KytJWpzxbfn3/mh6mvTpP+S8mj5jLPZJG42K/ZpQ
	 BzfB9sUMB45K1JW9esL+sNittsIPbM9eTjiPqV89FjonQY0yYnr7inGtPMjg5lj1Fpcop
	 HC2prs7pkCp5+Be1ck19ntiu5ivaT0k6eaEAsvBbk9rVIzndoWmKiS3fsFHobKBQ61Dde
	 mFXT6fNMK0ho3L/YjgkEZ/J4qMmooz9qb3qZZEYaygxaL72FqB74sw+twx+bO6Q2oLevB
	 AjV7qOUp8GXB/ZGOzttJU3QH+0YJsDhmCS22BuuCO+PKSRYX7VkRXcvb05owTent8rg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793299544;
	h=DMARC-Filter:DKIM-Signature:Received:X-MC-Unique:
	 X-Mimecast-MFC-AGG-ID:Received:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:
	 X-Received:Received:Date:From:To:Cc:Subject:Message-ID:References:
	 MIME-Version:In-Reply-To:X-Mimecast-Spam-Score:X-Mimecast-MFC-PROC-ID:
	 X-Mimecast-Originator:Content-Type:Content-Disposition;
	bh=qWkhenp7xO3O5sxyR0lVzWMTjPb9BOaWzt69bViDjXQ=;
	b=ZHDeJXnyXDJb+1g6ovz4k95diePmqIq3SysqUc3mmBsaqrak8RdbjyZZXI62wwmW1i9k
	 32ASn80oImKCKyjtjn33fk0tRmiBuM+AJTx56GtqSl3GOfCKpyLpRHYgaYcww6eZjsd9c
	 x0e6PGoysFQmqFH8UxKy8t5cdBR3PDHOefCs8D4IBzDBXpn/9PL8qTN7ukLLpLUzHXVva
	 nnVqzrUQdfF5N4jjbS5X0qot6VA21ja96qwlrHFA2IcEC8m4aFivyCUXigvgv9o2hs6cU
	 VSay+x26xzm9cycYEQfgvCeJBCS4Rsnvp046BsrCr4yu/lPICMlZ9QTkLhSlB4FhZVg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=redhat.com;
	spf=pass smtp.mailfrom=redhat.com;
	dkim=pass header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=SvycTPma;
	arc=none smtp.remote-ip=170.10.129.124
Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 09450606A31A
	for <lvm-devel@lists.linux.dev>; Thu, 29 Oct 2026 18:45:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 09450606A31A
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key, unprotected) header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=SvycTPma
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1793299542;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=qWkhenp7xO3O5sxyR0lVzWMTjPb9BOaWzt69bViDjXQ=;
	b=SvycTPmar5UJOyUaEkYMxL4UE3FhBN4f0Cb/LP2RkMNtFjiGGBm0rQy0J/T4jybhkH2zWH
	jwS0YHd6EFWnNHH+c8N3LAh2QwXi4hBwbIdngzJQnjh30CEuNAqrTPdFZID4GH4AQCP+Cu
	IXcdpF7ao9L1y3/T0WEOIggjKZPYVr0=
Received: from mail-qv1-f71.google.com (mail-qv1-f71.google.com
 [209.85.219.71]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.3, cipher=TLS_AES_256_GCM_SHA384) id
 us-mta-127-h_49QOTNOjamxGtDW2N1TQ-1; Thu, 29 Oct 2026 14:45:38 -0400
X-MC-Unique: h_49QOTNOjamxGtDW2N1TQ-1
X-Mimecast-MFC-AGG-ID: h_49QOTNOjamxGtDW2N1TQ_1793299538
Received: by mail-qv1-f71.google.com with SMTP id 6a1803df08f44-91c70349f65so51293046d6.3
        for <lvm-devel@lists.linux.dev>; Thu, 29 Oct 2026 11:45:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1793299538; x=1793904338;
        h=in-reply-to:content-disposition:content-type:mime-version
         :references:message-id:subject:cc:to:from:date:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=qWkhenp7xO3O5sxyR0lVzWMTjPb9BOaWzt69bViDjXQ=;
        b=2GwFiFyl/d/VCePO+hWbVrqMxcZIBEG/H8H8LU3r80Syiq2/P5Jsp5/zBQTwWp0ezo
         KUqcHqxGcajtmXoG7GlrrVq/hdHklDpSEj/ft8aUXkwNtTLdfRFtVOL6iYmBVePD56Mm
         BlIEcwKarPAVLSmmPMV2vM6eCPH5TsXXDh1B/N32GtrGtXhsB5RkGWpnU93xCxW54lzx
         eZosLzgHhdgy5sB4QeaRYXuzGkP+bMsbKOaO7NRH/EmSU/Y+HdzfTyJJC+qgrRBlgvkH
         Thu34zsltQhzg8h5v0oyi3aorFB519RcsBlmvnRrmlihEBBDn3ItaWEvBVADc0CEShnz
         7iYQ==
X-Forwarded-Encrypted: i=1; AKwUvBwqto6UID7AzUkE8fMqGv9dytUyvicljn9W9Om6S4iJZGzfK6X5e4GDsxAu8eXSh8fYXQQJUc15TEI=@lists.linux.dev
X-Gm-Message-State: AFq9FYLvvpOUobGgg1+xP5G/uDj6cqcaNtB0zLP+ffI83vI3MP4dtaYj
	MbMibSMeijMeFPrSKzSptaXP9nL8SnvY9fsBrZyPZUDg28uRnWognL7dG9n7g8q10dgHBFfFsc5
	QHkpkgPXB0+spkdQpoD3HzxI7vXLsfACOtYKmXU6+8MEWx5gFm+VOqy1rwR8mZg==
X-Gm-Gg: AYBFou0BVvlJ1z1Fbj8ZQZ74hw5BL62xwDLWIh2IM5D7lx4UB0jiaHncr67TwtBbcEZ
	BtjnTPEdwaqtymMLz4gQBghYWcIyvvDj/VmGr/XDZ4KONMy26w0fh21UxjB8CLPr+4wW6mv2dpV
	TN1JwTBTK6DPwyaTY/EE+qhx0nyWYhkmcP7EbDK4bz5U4dsPJswr+zQ7p/HofkBBF4C06plpDMe
	/yCtqlYkwq3JiUl3y416TK11S2LCvV+h15c3+uJyUa0JpgNQ6MHCdoqJVpo1cn2Y2zHBp+AA8am
	OB6+nm6gGAgmcRZl/kXcLvV4wC/4EdjR164v6rLcL4sC5RZpugys7WVZZvYYNIGntwkjnGfF6kg
	8aHWbJVqyIUYs9D1kyHf0zUAcMrR1y7s3muGwvYJwrBuxcht7DDVw0SUUQ34gdyIDC2JHZYo=
X-Received: by 2002:a05:620a:2a08:b0:93e:b729:879e with SMTP id af79cd13be357-944216b6cb4mr15910285a.23.1793299538082;
        Thu, 29 Oct 2026 11:45:38 -0700 (PDT)
X-Received: by 2002:a05:620a:2a08:b0:93e:b729:879e with SMTP id af79cd13be357-944216b6cb4mr15904185a.23.1793299537436;
        Thu, 29 Oct 2026 11:45:37 -0700 (PDT)
Received: from localhost ([2600:1701:430:16b0:4dc8:4da9:ba0d:f3c1])
        by smtp.gmail.com with ESMTPSA id af79cd13be357-9442122ca9dsm13258285a.23.2026.10.29.11.45.36
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 29 Oct 2026 11:45:37 -0700 (PDT)
Date: Thu, 29 Oct 2026 13:45:36 -0500
From: David Teigland <teigland@redhat.com>
To: Itai Handler <itai.handler@gmail.com>
Cc: Zdenek Kabelac <zkabelac@redhat.com>, lvm-devel@lists.linux.dev
Subject: Re: [PATCH] label: fix writes when the logical block size is not 512
 or 4096
Message-ID: <auOUULF672SkVzt8@redhat.com>
References: <20261029125312.3631129-1-itai.handler@gmail.com>
 <e297d16a-58e9-40b2-9f1d-8baaf29e823e@redhat.com>
 <20261029135355.3690645-1-itai.handler@gmail.com>
X-Mailing-List: lvm-devel@lists.linux.dev
List-Id: <lvm-devel.lists.linux.dev>
List-Post: <mailto:lvm-devel@lists.linux.dev>
List-Help: <mailto:lvm-devel+help@lists.linux.dev>
List-Subscribe: <mailto:lvm-devel+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:lvm-devel+unsubscribe@lists.linux.dev>
List-Owner: <mailto:lvm-devel+owner@lists.linux.dev>
Precedence: list
MIME-Version: 1.0
In-Reply-To: <20261029135355.3690645-1-itai.handler@gmail.com>
X-Mimecast-Spam-Score: 0
X-Mimecast-MFC-PROC-ID: jCqMR4ZuJL6lgCPUxw609k7GPhZzsd3w2hYkf1JNyTo_1793299538
X-Mimecast-Originator: redhat.com
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Thu, Oct 29, 2026 at 03:53:55PM +0200, Itai Handler wrote:
> Whichever size is used, the cost to LVM is small.  Only LVM's own
> writes, such as metadata updates, are rounded up to whole blocks,
> which adds less than one block to each, and they happen only when LVM
> changes something.  LV data does not go through this code, and the
> default 1MiB pe_start keeps extents aligned for any of these sizes.

This last line touches on the main concern I have with the rouding up.
dev_set_last_byte was added by aecf542126640faa17c240afbb1ea61f11355c39
which addressed a very subtle data corruption bug that was introduced
by the bcache (now blkio) layer.  In order to safely round up, we need
to be certain that no VGs exist in which that rounded up space could
be used by LV extents.  In the past (less so today), the pe_start value
could be highly variable due to several config settings or command
line options.  We'll need to prove that current and past versions of
lvm would not have placed pe_start within the rounded-up space.

Dave

