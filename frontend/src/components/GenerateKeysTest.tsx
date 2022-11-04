import React, { useState } from 'react';

const GenerateKeysTest = () => {

    const [aliceKeys, setAliceKeys] = useState({
        private: '',
        public: ''
    });

    const [bobKeys, setBobKeys] = useState({
        private: '',
        public: ''
    });

    const [sharedSecret, setSharedSecret] = useState('');

    const [encryptedMessage, setEncryptedMessage] = useState(new Uint8Array());
    const [iv, setIv] = useState(new Uint8Array());

    const [decryptedMessage, setDecryptedMessage] = useState('');

    const [message, setMessage] = useState('');

    const inputHandler = (event: { target: { value: React.SetStateAction<string>; }; }) => {
        setMessage(event.target.value);
    };

    const GenerateKeys = async () => {
        const aliceKeyPair = await window.crypto.subtle.generateKey(
            {
              name: "ECDH",
              namedCurve: "P-384"
            },
            true,
            ["deriveKey", "deriveBits"]
        );
        
        const alicePublicKeyExport = await window.crypto.subtle.exportKey(
            "jwk",
            aliceKeyPair.publicKey
        );
        
        const alicePrivateKeyExport = await window.crypto.subtle.exportKey(
            "jwk",
            aliceKeyPair.privateKey
        );

        setAliceKeys({public: JSON.stringify(alicePublicKeyExport), private: JSON.stringify(alicePrivateKeyExport)});

        const bliceKeyPair = await window.crypto.subtle.generateKey(
            {
              name: "ECDH",
              namedCurve: "P-384"
            },
            true,
            ["deriveKey", "deriveBits"]
        );
        
        const bobPublicKeyExport = await window.crypto.subtle.exportKey(
            "jwk",
            bliceKeyPair.publicKey
        );
        
        const bobPrivateKeyExport = await window.crypto.subtle.exportKey(
            "jwk",
            bliceKeyPair.privateKey
        );

        setBobKeys({public: JSON.stringify(bobPublicKeyExport), private: JSON.stringify(bobPrivateKeyExport)});
    }

    const GenerateSecret = async () => {

        const publicKey = await window.crypto.subtle.importKey(
            "jwk",
            JSON.parse(aliceKeys.public),
            {
                name: "ECDH",
                namedCurve: "P-384",
            },
            true,
            []
        );
    
        const privateKey = await window.crypto.subtle.importKey(
            "jwk",
            JSON.parse(bobKeys.private),
            {
                name: "ECDH",
                namedCurve: "P-384",
            },
            true,
            ["deriveKey", "deriveBits"]
        );
    
        const sharedSecret =  await window.crypto.subtle.deriveKey(
            { name: "ECDH", public: publicKey },
            privateKey,
            { name: "AES-GCM", length: 256 },
            true,
            ["encrypt", "decrypt"]
        );

        const sharedKeyExport = await window.crypto.subtle.exportKey(
            "jwk",
            sharedSecret
        );

        setSharedSecret(JSON.stringify(sharedKeyExport));
    }

    const EncryptMessage = async () => {

        const publicKey = await window.crypto.subtle.importKey(
            "jwk",
            JSON.parse(aliceKeys.public),
            {
                name: "ECDH",
                namedCurve: "P-384",
            },
            true,
            []
        );
    
        const privateKey = await window.crypto.subtle.importKey(
            "jwk",
            JSON.parse(bobKeys.private),
            {
                name: "ECDH",
                namedCurve: "P-384",
            },
            true,
            ["deriveKey", "deriveBits"]
        );
    
        const sharedSecret =  await window.crypto.subtle.deriveKey(
            { name: "ECDH", public: publicKey },
            privateKey,
            { name: "AES-GCM", length: 256 },
            true,
            ["encrypt", "decrypt"]
        );

        const encodedMessage = new TextEncoder().encode(message);
        const iv = new TextEncoder().encode("Initialization Vector");
        
        setIv(iv);

        const cypherText = await window.crypto.subtle.encrypt(
            { name: "AES-GCM", iv: iv },
            sharedSecret,
            encodedMessage
        );

        const cypherArray = new Uint8Array(cypherText);

        setEncryptedMessage(cypherArray);
    }

    const DecryptMessage = async () => {

        const key = await window.crypto.subtle.importKey(
            "jwk",
            JSON.parse(sharedSecret),
            "AES-GCM",
            true,
            ["encrypt", "decrypt"]
        );

        const algorithm = {
            name: "AES-GCM",
            iv: iv,
        };
        const decryptedData = await window.crypto.subtle.decrypt(
            algorithm,
            key,
            encryptedMessage
        );

        setDecryptedMessage(new TextDecoder().decode(decryptedData));
    }
    
    return (
        <div>
            <div>
                <h3>Key Generation</h3>
                <button onClick={GenerateKeys}>Generate</button>
                <p>Alice Public Key = {aliceKeys.public}</p>
                <p>Alice Private Key = {aliceKeys.private}</p>
                <p>Bob Public Key = {bobKeys.public}</p>
                <p>Bob Private Key = {bobKeys.private}</p>
            </div>
            <div>
                <h3>Generate Secret</h3>
                <button onClick={GenerateSecret}>Generate</button>
                <p>Shared Secret = {sharedSecret}</p>
            </div>
            <div>
                <h3>Encrypt Message</h3>
                <input type="text" id="message" name="message" onChange={inputHandler} value={message}/>
                <button onClick={EncryptMessage}>Encrypt</button>
                <p>Encrypted Message = {encryptedMessage}</p>
            </div>
            <div>
                <h3>Decrypt Message</h3>
                <button onClick={DecryptMessage}>Decrypt</button>
                <p>Decrypted Message = {decryptedMessage}</p>
            </div>
        </div>
    )
};

export default GenerateKeysTest;