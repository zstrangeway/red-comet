export function checkParams(
  body: Record<string, unknown>,
  params: Array<string>
): Array<string> {
  const missingParams: Array<string> = [];
  params.forEach((param) => {
    if (!(param in body)) missingParams.push(param);
  });
  return missingParams;
}
