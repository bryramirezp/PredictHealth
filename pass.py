import bcrypt

def generar_hash(password: str) -> str:
    password_bytes = password.encode('utf-8')
    salt = bcrypt.gensalt()
    hashed = bcrypt.hashpw(password_bytes, salt)
    return hashed.decode('utf-8')

# Credenciales específicas
creds = [
    ("admin", "Admin", "admin@predicthealth.com", "Admin123!"),
    ("editor", "Editor", "editor@predicthealth.com", "Editor123!")
]

# Imprimir usuario, email, contraseña y hash
for username, rol, email, pwd in creds:
    hash_pwd = generar_hash(pwd)
    print(f"{username}: {email}  /  {pwd}")
    print(f"Rol: {rol}")
    print(f"Password Hash: {hash_pwd}\n")
