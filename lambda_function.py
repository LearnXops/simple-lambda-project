# lambda_function.py
def handler(event, context):
    name = (event or {}).get("name", "World")
    print(f"Invoked with event: {event}")  # goes to CloudWatch Logs
    return {"message": f"Hello, {name} 👋"}
