FROM public.ecr.aws/lambda/nodejs:18

# Copy package files and install dependencies
COPY package*.json ${LAMBDA_TASK_ROOT}/
RUN npm install --production

# Copy application source code
COPY src/ ${LAMBDA_TASK_ROOT}/src/

# Set the command handler
CMD [ "src/index.handler" ]