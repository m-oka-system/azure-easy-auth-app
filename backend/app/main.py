import base64
import json
from fastapi import FastAPI, Request
from pydantic import BaseModel
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

class Item(BaseModel):
    name: str
    price: float

# @app.get("/")
# async def root():
#     return {"message": "Hello World"}

@app.get("/")
async def read_root(request: Request):
    # ヘッダから特定の値を取得
    client_principal = request.headers.get("X-MS-CLIENT-PRINCIPAL", "Not available")
    client_principal_id = request.headers.get("X-MS-CLIENT-PRINCIPAL-ID", "Not available")
    principal_name = request.headers.get("X-MS-CLIENT-PRINCIPAL-NAME", "Not available")
    principal_idp = request.headers.get("X-MS-CLIENT-PRINCIPAL-IDP", "Not available")
    access_token = request.headers.get("X-MS-TOKEN-AAD-ACCESS-TOKEN", "Not available")

    if client_principal:
        try:
            # Base64 デコード
            decoded_principal = base64.b64decode(client_principal)
            # JSONとしてパース
            principal_json = json.loads(decoded_principal)
        except Exception as e:
            principal_json = {"error": f"Failed to decode or parse X-MS-CLIENT-PRINCIPAL: {e}"}
    else:
        principal_json = {"error": "X-MS-CLIENT-PRINCIPAL header not found"}

    return {
        "X-MS-CLIENT-PRINCIPAL": client_principal,
        "X-MS-CLIENT-PRINCIPAL-DECORD": principal_json,
        "X-MS-CLIENT-PRINCIPAL-ID": client_principal_id,
        "X-MS-CLIENT-PRINCIPAL-NAME": principal_name,
        "X-MS-CLIENT-PRINCIPAL-IDP": principal_idp,
        "X-MS-TOKEN-AAD-ACCESS-TOKEN": access_token,
    }

@app.get("/items/{item_id}")
def read_item(item_id: int, q: str = None):
    if q:
        return {"item_id": item_id, "q": q}
    return {"item_id": item_id}

@app.post("/items")
def update_item(item: Item):
    return {"item_name": item.name, "twice price": item.price * 2}
