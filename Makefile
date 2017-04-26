ca = ca
days = 3650
t = $(ca)

all: $(t).crt
	$(RM) *.key

clean:
	@git clean -X || echo "run git config clean.requireForce false"

SIG = openssl x509 -days $(days) -req -in $*.req -out $*.crt -CAcreateserial
ifeq ($(t),$(ca))
%.crt: %.req %.key
	$(SIG) -signkey $*.key
else
%.crt: %.req $(ca).crt $(ca).key
	$(SIG) -CA $(ca).crt -CAkey $(ca).key
endif

%.req: %.key
	openssl req -batch -new -key $< -out $@ -subj "/CN=$*"

%.key: %.key.gpg ; umask 077; gpg $<
%.key: %.key.asc ; umask 077; gpg $<
%.key:
	umask 077; openssl genrsa -out $@
	gpg -e $@
