Received: from outbound.soverin.net (outbound.soverin.net [185.233.34.146])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6101828033B
	for <lvm-devel@lists.linux.dev>; Sat, 26 Sep 2026 12:12:25 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=185.233.34.146
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790424749; cv=none; b=BWKLBZ46l2a5yaB85NUjN+iGg6aq2GaKDrF5qt30HohuXkx9ykubUGkUoaPzXk/60vZsQn0bsdp7xYxNcIFigYMmCdP28GAlVZy/pTlDrkL9hugEsRFB3fLSoq/qzb+sP2P0ArBiSNftdzWAuUVXjnq6d01r7TRTVLBTKY55rKY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790424749; c=relaxed/simple;
	bh=uq6fnxr9IV8zdCQXrZSWZBksEhE8uOCbkRHbq70WYuY=;
	h=MIME-Version:Date:From:To:Subject:Message-ID:Content-Type; b=I2xgzpLy2EaPbNy6f7x9QjV762LFiylqwCllVDqUyGMF7yMtfY8vmujurBJwG/Gsbyyt034irQkcKwpjD3AIZdG1Ek46d2IGA0GjuheYhiN0/d1HGW2zU5D2EdrLtXxKUQlKnulyiSY83MEIzX2cjGvWNZx1nglKRsKPF5UrCGs=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=freedom.nl; spf=pass smtp.mailfrom=freedom.nl; dkim=pass (2048-bit key) header.d=freedom.nl header.i=@freedom.nl header.b=DB6N3/L5; arc=none smtp.client-ip=185.233.34.146
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=freedom.nl
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=freedom.nl
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=freedom.nl header.i=@freedom.nl header.b="DB6N3/L5"
Received: from smtp.soverin.net (unknown [10.10.4.100])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by outbound.soverin.net (Postfix) with ESMTPS id 4hsRK32Hqvz1xp1
	for <lvm-devel@lists.linux.dev>; Sat, 26 Sep 2026 12:12:23 +0000 (UTC)
Received: from smtp.soverin.net (smtp.soverin.net [10.10.4.100]) by soverin.net (Postfix) with ESMTPSA id 4hsRK31PfPzKh
	for <lvm-devel@lists.linux.dev>; Sat, 26 Sep 2026 12:12:23 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=freedom.nl; s=soverin1;
	t=1790424743;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:mime-version:mime-version:content-type:content-type;
	bh=uq6fnxr9IV8zdCQXrZSWZBksEhE8uOCbkRHbq70WYuY=;
	b=DB6N3/L5U8iEdYJxtzQnYqQzUjd/OBlniYZloZIiTXmX9Hl05nPpH7SuqtB1lBT6LPPa4P
	JI8YETSGQV208UEnZsNOXD2xo3nHQqRTYSdKt8aeTGVGANA74zo5fesSkaXjlnBiOY48fE
	4jsXNc/QABAxyW1SwbK0yvku6Tv42UJ+2RyXEyH1OvoyjF3Kuojil63sUIULAE9mfpHde5
	UVWTcc+2BuOfpEo3U3sJ1aGckCz/mrQmlJCGqu//OYW5NX0qFRXDQjh0hT/EJNm4cSCRGW
	TsMR4gApaKCSYHvwBTsLKLUvqyoicEOJD7R1sUBKtzcxVFE8JpusmkoQW4kstw==
X-CM-Envelope: MS4xfEKpKKCkYtOgy6MU3vVWBw8K0cEYuD/2dk2Xg91GnLi0mgiXF85IARSrTtg7SfUROH0oBiNod8wyvBl6H4gRFY7Q+sDjKyKEv3V0FrvSGk7jW7tZwg4i 8XsPN4ztcx270EOdsxMqJOzrTlN2EqzobD4T3vJshfKpvYpOTn21UGvVTdDwVncwJFjyjW76OQkHfg==
X-Soverin-Id: 01a0dda1-7c58-78d0-b293-31aac54a7266
Precedence: bulk
X-Mailing-List: lvm-devel@lists.linux.dev
List-Id: <lvm-devel.lists.linux.dev>
List-Subscribe: <mailto:lvm-devel+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:lvm-devel+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Date: Sat, 26 Sep 2026 12:12:23 +0000
From: Paul van Genderen - Tjie A Loi <paul.vangenderen@freedom.nl>
To: lvm-devel@lists.linux.dev
Subject: Missing path component in dmsetup(8) manual page
Message-ID: <d979be8a93464508f3944a2a3165d723@freedom.nl>
Content-Type: multipart/mixed;
 boundary="=_11fca65cdcf7a8bf60ae463c013832b2"
X-Spampanel-Class: ham

--=_11fca65cdcf7a8bf60ae463c013832b2
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=US-ASCII;
 format=flowed

Hello,

I noticed a missing path component in the manual page for dmsetup.
The path mentioned was: Documentation/device-mapper but it should
be: Documentation/admin-guide/device-mapper.
Attached patch fixes the problem and I've tried to ensure line
breaks happen in the right places.

Regards,
Paul
--=_11fca65cdcf7a8bf60ae463c013832b2
Content-Transfer-Encoding: base64
Content-Type: text/x-diff;
 name*0*=UTF-8''dmsetup_manual_page_correct_kernel_source_tree_documentati;
 name*1*=on_path.patch
Content-Disposition: attachment;
 filename*0*=UTF-8''dmsetup_manual_page_correct_kernel_source_tree_documen;
 filename*1*=tation_path.patch;
 size=472

LS0tIGEvbWFuL2Rtc2V0dXAuOF9tYWluCisrKyBiL21hbi9kbXNldHVwLjhfbWFpbgpAQCAtMTEy
NCw3ICsxMTI0LDcgQEAgYmV0dGVyIHNuYXBzaG90IHN1cHBvcnQuCiAuUAogVG8gZmluZCBvdXQg
bW9yZSBhYm91dCB0aGUgdmFyaW91cyB0YXJnZXRzIGFuZCB0aGVpciB0YWJsZSBmb3JtYXRzCiBh
bmQgc3RhdHVzIGxpbmVzLCBwbGVhc2UgcmVhZCB0aGUgZmlsZXMgaW4KLXRoZSBEb2N1bWVudGF0
aW9uL2RldmljZS1tYXBwZXIgZGlyZWN0b3J5Cit0aGUgRG9jdW1lbnRhdGlvbi9cOlwlYWRtaW4t
Z3VpZGUvXDpcJWRldmljZS1tYXBwZXIgZGlyZWN0b3J5CiBpbiB0aGUga2VybmVsIHNvdXJjZSB0
cmVlLgogKFlvdXIgZGlzdHJpYnV0aW9uIG1pZ2h0IGluY2x1ZGUgYSBjb3B5IG9mIHRoaXMgaW5m
b3JtYXRpb24gaW4gdGhlCiBkb2N1bWVudGF0aW9uIGRpcmVjdG9yeSBmb3IgdGhlIGRldmljZS1t
YXBwZXIgcGFja2FnZS4pCg==
--=_11fca65cdcf7a8bf60ae463c013832b2--
