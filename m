Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=170.10.129.124
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793785018;
	b=ph3SC2DF8JEwsd56ZRW5ej0aj0OjubXYuoVoHa3A9xKcDKypiV83HTZWCQ38TaR4ONE4
	 X1uJdtZ8dXyvTVOJVl3mW1vlXbSX2+nUIHKBAnRGn7Rgv9J3eDNHbp+WnR0A6HrKQ73+7
	 R5RX7y9UkeyULGhKNq7hcWy+pvzBSevyEbPJRjAUNeyT22vz4Anddm3JYh2NjUTYItfFa
	 aD4KVytPL+xc09NfZIKh6civd8i3+FA2fXDlNcuLoFUtZh/M7UGtQuyELbw8d+bcaGnZ3
	 MsSQf0AVYZR9kW63V/g0Vp9+7ehGsrkxMKnKqvcMFa61rDe5a9ELNpALpHukMFjAf/w==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793785018;
	h=DMARC-Filter:DKIM-Signature:Received:X-MC-Unique:
	 X-Mimecast-MFC-AGG-ID:Received:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:
	 X-Received:Received:Message-ID:Date:MIME-Version:User-Agent:Subject:
	 To:References:From:Organization:In-Reply-To:X-Mimecast-Spam-Score:
	 X-Mimecast-MFC-PROC-ID:X-Mimecast-Originator:Content-Language:
	 Content-Type:Content-Transfer-Encoding;
	bh=3u3CaEbxfnWx9Q5ijhi+ZhfGrmGDTVHxkoFt21rV79A=;
	b=C1RG+ONBDPF0Cc3sBlrHpKl2vxVUHdMlG069Rlo+fzlRaU5vPOSmw3dQArpGy3PTK59c
	 ogy5JIjTBG98DiZ8gzLM1exGeJ6YjKrtIKgootj/ZPRBgC3FUargQ80jQDaCI2IXbq58d
	 zQr06DbVKiFJNKvamzcqNP/zjF7LwmJVC1X99AeZyJN5QIwkvoVZsQqK0qWW3HrX0zmPl
	 Xhj768Sb+6nnfdYxA0BMMTnv6V8Jkl6u344tYVgAsqYjnYV3jZQNCEWftLGCB/Qu51DNQ
	 BhGftCjXygtZDFDfQnekcgDO6rrz6oFv4/ZcWbDmbt7DF4W4J/1nAWJUzAcbKhKDIGQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=redhat.com;
	spf=pass smtp.mailfrom=redhat.com;
	dkim=pass header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=ZAGFh3dV;
	arc=none smtp.remote-ip=170.10.129.124
Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D5BBC606A31B
	for <lvm-devel@lists.linux.dev>; Wed,  4 Nov 2026 09:36:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org D5BBC606A31B
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key, unprotected) header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=ZAGFh3dV
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1793785016;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=3u3CaEbxfnWx9Q5ijhi+ZhfGrmGDTVHxkoFt21rV79A=;
	b=ZAGFh3dVUTokSZI6exsjgmcy5KQWowniX5q8EgeyM9uzqqrKEEgKzCdjjUqF74kDCyweE3
	jNdvNVgZ7PQt61GpFtafxvBkgQ7PRGggFCl770ZZuSlTgl+8+xHhV6rJCQb4V+SS13dUQ/
	JD9yoD0QP2Zzy9Xcc1d/bkixprIdy+0=
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com
 [209.85.128.70]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.3, cipher=TLS_AES_256_GCM_SHA384) id
 us-mta-117-yNTM5NBhO4q4jK3ZA_r4FA-1; Wed, 04 Nov 2026 04:36:55 -0500
X-MC-Unique: yNTM5NBhO4q4jK3ZA_r4FA-1
X-Mimecast-MFC-AGG-ID: yNTM5NBhO4q4jK3ZA_r4FA_1793785014
Received: by mail-wm1-f70.google.com with SMTP id 5b1f17b1804b1-4a35e1d2dddso5394535e9.0
        for <lvm-devel@lists.linux.dev>; Wed, 04 Nov 2026 01:36:55 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1793785014; x=1794389814;
        h=content-transfer-encoding:content-type:in-reply-to:organization
         :from:content-language:references:to:subject:user-agent:mime-version
         :date:message-id:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=3u3CaEbxfnWx9Q5ijhi+ZhfGrmGDTVHxkoFt21rV79A=;
        b=K+cycM+dcvMPHZYlMyDlYVbQ2+GiCV58Q8XVlzLInslVyGbc7QEigVsN4yt322NpDa
         Zn+rhGn9JTTMTC0D+S8QpmmyTjRbNw9AcDgacOe5+Z21Pg7LADPoJZ0Vx64lLY7qS+d6
         K2Oaqh96W12SyunoV38JxdDrVjhOfMQMMCUpO92P677lGz0oI4L38/2aHYPb5VqYupKw
         INGAuoPW6Q8aeP1CWoJzjm8yGxOY4kOALyWiRDJnbd7CTkGI+AZZEeX50lhmKqNdtDs0
         QwmcSSyGvLGEeg8iDhdIRr1y9HxKbtljYvp2Acf+HtW42gwFPkvhkdb8rJsZLyMftVAG
         D9qw==
X-Forwarded-Encrypted: i=1; AKwUvBw35SNSZbEVPfHOKewXOGyiJj01wxayySTHUKCMnWoZeWZKzEgrAEauFRYvqIqRZhVI5ItQQu0VOtE=@lists.linux.dev
X-Gm-Message-State: APuU4Z/5bF40nTj42DYcls10U6mksMHmja5dzAAV6g7QlC08HiD3Yfik
	YMMWJgUAZSrlRTAlKS4divND0oJ6jEFeRR3dGR4NELACaUr2euswpkuDY9K9GyFicCrq6Gsu7+k
	GJNqgB82w4VRnYP+hSd8X8qCXVYWUh9x/rqFPfBcsZjsYGLCF9JiRrp9D8bqtPQ==
X-Gm-Gg: AYBFou1+7dHsuzM7y3GO2UKGwoz1YXuFfjV+U+GUq+wqU4qivNdhV2n1bYZAMBSK3yd
	5l4SeXBUfl/1uZLuDEAPCdilg96+6/HlhInKpwDMkdF0fjv7FesUZI4gd9aa4NjOnaaKKEvhpVZ
	Q/BQcYav821x5l2Cl5odl3HIDoJxmKWEahZ6bWeMFMvxgOP/Och/EXea9COAgJP+ZM3511vjJNH
	ey7P4T0K2xyG+Zbstk00bg6/krjT3haBiM7C/X964Ylzr/5ToWa//mLaitVUathEFeR4QCEK7fr
	5um34Qe4xkGdtKwf5fJgX1fuAviS+MvDv/iNr5TSeoTatYhyq4P4qhW0wBG4rii/iY7n7f8rpmt
	Zh5fj+9EGcia2uif1rQA4WhfrlRi2lGk=
X-Received: by 2002:a05:600c:3b87:b0:4a2:150f:1607 with SMTP id 5b1f17b1804b1-4ac1709ad56mr373127845e9.13.1793785014319;
        Wed, 04 Nov 2026 01:36:54 -0800 (PST)
X-Received: by 2002:a05:600c:3b87:b0:4a2:150f:1607 with SMTP id 5b1f17b1804b1-4ac1709ad56mr373127495e9.13.1793785013872;
        Wed, 04 Nov 2026 01:36:53 -0800 (PST)
Received: from [10.43.17.4] ([213.175.46.86])
        by smtp.gmail.com with ESMTPSA id 5b1f17b1804b1-4b2ab00ff3dsm231892425e9.14.2026.11.04.01.36.53
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Wed, 04 Nov 2026 01:36:53 -0800 (PST)
Message-ID: <713023c3-32a4-426e-bc2e-2b93b3f2a97d@redhat.com>
Date: Wed, 4 Nov 2026 10:36:53 +0100
X-Mailing-List: lvm-devel@lists.linux.dev
List-Id: <lvm-devel.lists.linux.dev>
List-Post: <mailto:lvm-devel@lists.linux.dev>
List-Help: <mailto:lvm-devel+help@lists.linux.dev>
List-Subscribe: <mailto:lvm-devel+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:lvm-devel+unsubscribe@lists.linux.dev>
List-Owner: <mailto:lvm-devel+owner@lists.linux.dev>
Precedence: list
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH] test: skip metadata-write-rounding with pages larger than
 4KiB
To: Itai Handler <itai.handler@gmail.com>, lvm-devel@lists.linux.dev
References: <20261104065729.1305748-1-itai.handler@gmail.com>
From: Zdenek Kabelac <zkabelac@redhat.com>
Organization: RedHat
In-Reply-To: <20261104065729.1305748-1-itai.handler@gmail.com>
X-Mimecast-Spam-Score: 0
X-Mimecast-MFC-PROC-ID: zL4JONqvkCZQlVPOxZrMwCDtTwQUjb3fHVQGKp_4tnw_1793785014
X-Mimecast-Originator: redhat.com
Content-Language: en-US, cs-CZ
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Dne 04. 11. 26 v 7:57 Itai Handler napsal(a):
> On kernels configured with 64KiB pages, pvcreate in the test fails:
> 
>    Metadata area size too small: 66560 bytes. It must be at least 524288 bytes.
> 
> The metadata area starts at the page size and is at least 8 pages long,
> so it can end one logical block after 64KiB, as the test needs, only
> with 4KiB pages.  Skip the test with larger pages.
> 
Hi

Here I've my local repo with longer list of test fixes for 64K pages - this 
will be pushed to origin once it will be polished.

Regards

Zdenek

