# Coolify Deployment Guide for FBMN-STATS

This guide provides instructions for deploying the FBMN-STATS application using Coolify's auto-deployment feature.

## Prerequisites

- Coolify instance running (v4.0 or later)
- Git repository access
- Domain name (optional but recommended)
- Docker support enabled

## Quick Deployment

### Option 1: Auto-Deployment via Coolify UI

1. **Access Coolify Dashboard**
   - Log into your Coolify instance
   - Navigate to "Projects" or "Applications"

2. **Create New Application**
   - Click "New Resource" → "Application"
   - Select "Docker Compose" as the build pack

3. **Configure Repository**
   - **Repository URL**: `https://github.com/Functional-Metabolomics-Lab/FBMN-STATS.git`
   - **Branch**: `main`
   - **Docker Compose File**: `docker-compose-coolify.yml`
   - **Auto-deploy**: Enable

4. **Application Settings**
   - **Name**: `fbmn-stats`
   - **Port**: `8502`
   - **Health Check Path**: `/_stcore/health`
   - **Build Pack**: Docker Compose

### Option 2: Manual Docker Compose Deployment

1. **Clone Repository**
   ```bash
   git clone https://github.com/Functional-Metabolomics-Lab/FBMN-STATS.git
   cd FBMN-STATS
   ```

2. **Deploy with Coolify Docker Compose**
   ```bash
   docker-compose -f docker-compose-coolify.yml up -d
   ```

3. **Verify Deployment**
   ```bash
   docker-compose -f docker-compose-coolify.yml ps
   docker-compose -f docker-compose-coolify.yml logs fbmn-stats
   ```

## Coolify-Specific Configuration

### Environment Variables

Coolify automatically manages these environment variables:

| Variable | Default | Description |
|----------|---------|-------------|
| `COOLIFY_FQDN` | Auto-generated | Fully qualified domain name |
| `STREAMLIT_SERVER_PORT` | `8502` | Application port |
| `STREAMLIT_SERVER_ADDRESS` | `0.0.0.0` | Bind address |
| `STREAMLIT_SERVER_HEADLESS` | `true` | Run in headless mode |
| `STREAMLIT_SERVER_MAX_UPLOAD_SIZE` | `512` | Max upload size (MB) |

### Domain Configuration

1. **Automatic Domain**
   - Coolify automatically assigns a subdomain
   - Format: `fbmn-stats.your-coolify-domain.com`

2. **Custom Domain**
   - Add your custom domain in Coolify dashboard
   - Update DNS records to point to your Coolify instance
   - SSL certificates are automatically managed

### Resource Limits

Default resource allocation in Coolify:
- **Memory**: 2GB (configurable)
- **CPU**: 1 core (configurable)
- **Storage**: Persistent volume for user data

## File Structure

```
.
├── docker-compose-coolify.yml  # Coolify-specific deployment
├── docker-compose.yml          # Standard deployment
├── Dockerfile                  # Container build instructions
├── COOLIFY-DEPLOYMENT.md       # This file
├── .streamlit/config.toml      # Streamlit configuration
└── requirements.txt            # Python dependencies
```

## Coolify Labels and Features

### Optimized Configuration
The `docker-compose-coolify.yml` file has been optimized for Coolify deployment with the following improvements: <mcreference link="https://coolify.io/docs/knowledge-base/docker/compose" index="1">1</mcreference>

**Key Changes Made:**
- **Removed explicit Traefik labels**: Coolify automatically adds required Traefik labels
- **Removed container_name**: Coolify manages container naming
- **Changed ports to expose**: Uses `expose` instead of `ports` for better security
- **Removed host volume mounts**: Application files are built into the container
- **Added Coolify magic variables**: Uses `SERVICE_FQDN_FBMN` for dynamic URL generation
- **Simplified labels**: Only includes essential `coolify.managed=true` label
- **Removed custom networks**: Coolify manages networking automatically

### Managed Labels
The deployment includes minimal Coolify-specific labels:
- `coolify.managed=true` - Marks resources as Coolify-managed

### Health Checks
- **Endpoint**: `/_stcore/health`
- **Interval**: 30 seconds
- **Timeout**: 10 seconds
- **Retries**: 3
- **Start Period**: 40 seconds

### Automatic Features
- **SSL/TLS**: Automatically managed by Coolify <mcreference link="https://coolify.io/docs/knowledge-base/docker/compose" index="1">1</mcreference>
- **Reverse Proxy**: Traefik integration automatically configured
- **Monitoring**: Built-in health monitoring
- **Logging**: Centralized log management
- **Backups**: Automatic volume backups
- **Domain Management**: Automatic subdomain generation
- **Load Balancing**: Built-in load balancer configuration

## Monitoring and Logs

### View Logs in Coolify
1. Navigate to your application in Coolify dashboard
2. Click on "Logs" tab
3. View real-time application logs

### Command Line Monitoring
```bash
# View application logs
docker-compose -f docker-compose-coolify.yml logs -f fbmn-stats

# Check container status
docker-compose -f docker-compose-coolify.yml ps

# Monitor resources
docker stats fbmn-stats-app
```

## Troubleshooting

### Common Issues

1. **ModuleNotFoundError: No module named 'src.common'**
   - **Solution**: Ensure `PYTHONPATH=/app` is set in environment variables
   - **Additional Fix**: The `src` directory must contain an `__init__.py` file to be recognized as a Python package
   - Both fixes are already configured in the deployment files
   - The error occurs when Python can't find the `src` module directory or it's not recognized as a package

2. **Application Won't Start**
   - Check Coolify application logs
   - Verify Docker Compose file syntax
   - Ensure port 8502 is not in use
   - Check resource availability

3. **Domain/SSL Issues**
   - Verify DNS configuration
   - Check Coolify proxy settings
   - Ensure domain points to Coolify instance IP
   - Wait for SSL certificate provisioning (up to 10 minutes)

4. **Upload/Performance Issues**
   - Check volume permissions in Coolify
   - Monitor memory usage in dashboard
   - Increase resource limits if needed
   - Verify disk space availability

5. **Health Check Failures**
   - Verify application is responding on port 8502
   - Check if Streamlit is fully initialized
   - Review application startup logs

### Debug Commands

```bash
# Enter container for debugging
docker-compose -f docker-compose-coolify.yml exec fbmn-stats bash

# Test health endpoint
curl -I http://localhost:8502/_stcore/health

# Check network connectivity
docker network ls
docker network inspect fbmn-stats-network

# View detailed container info
docker inspect fbmn-stats-app
```

## Scaling and Performance

### Horizontal Scaling
Coolify supports horizontal scaling:
1. Navigate to application settings
2. Adjust "Replicas" count
3. Coolify handles load balancing automatically

### Vertical Scaling
To increase resources:
1. Go to application "Configuration"
2. Modify "Resource Limits"
3. Set memory and CPU limits
4. Restart application

### Performance Optimization
- Enable Coolify's built-in caching
- Use SSD storage for volumes
- Monitor resource usage regularly
- Consider CDN for static assets

## Security Features

### Built-in Security
- **Automatic SSL**: Let's Encrypt integration
- **Network Isolation**: Container networking
- **File Upload Limits**: 512MB default
- **Security Headers**: Automatic HTTPS headers

### Additional Security
- Regular security updates via auto-deployment
- Container image scanning (if enabled)
- Access logs and monitoring
- Firewall rules managed by Coolify

## Backup and Recovery

### Automatic Backups
Coolify provides automatic backup features:
- **Volume Backups**: Daily snapshots of persistent data
- **Configuration Backups**: Application settings
- **Database Backups**: If applicable

### Manual Backup
```bash
# Backup application data
docker run --rm -v fbmn-stats_app-data:/data -v $(pwd):/backup alpine tar czf /backup/fbmn-stats-backup.tar.gz -C /data .

# Restore from backup
docker run --rm -v fbmn-stats_app-data:/data -v $(pwd):/backup alpine tar xzf /backup/fbmn-stats-backup.tar.gz -C /data
```

## Updates and Maintenance

### Auto-Updates
Coolify supports automatic updates:
1. Enable "Auto Deploy" in application settings
2. Configure webhook for Git repository
3. Updates deploy automatically on new commits

### Manual Updates
1. Navigate to application in Coolify
2. Click "Deploy" button
3. Monitor deployment progress
4. Verify application health

### Maintenance Mode
```bash
# Enable maintenance mode
docker-compose -f docker-compose-coolify.yml stop

# Perform maintenance
# ...

# Resume normal operation
docker-compose -f docker-compose-coolify.yml up -d
```

## Integration with Coolify Features

### Notifications
- Configure Discord/Slack notifications
- Set up email alerts for failures
- Monitor deployment status

### Metrics and Analytics
- Built-in resource monitoring
- Application performance metrics
- Custom dashboard creation

### Team Collaboration
- Multi-user access control
- Role-based permissions
- Audit logs and activity tracking

## Migration from Other Platforms

### From Docker Compose
1. Use existing `docker-compose.yml` as base
2. Add Coolify-specific labels
3. Configure domain and SSL
4. Test deployment

### From EasyPanel
1. Export application configuration
2. Adapt to Coolify format
3. Migrate persistent data
4. Update DNS records

## Support and Resources

### Documentation
- [Coolify Official Docs](https://coolify.io/docs)
- [Docker Compose Reference](https://docs.docker.com/compose/)
- [FBMN-STATS GitHub](https://github.com/Functional-Metabolomics-Lab/FBMN-STATS)

### Community Support
- Coolify Discord Community
- GitHub Issues for application-specific problems
- Stack Overflow for technical questions

### Professional Support
- Coolify Pro for enterprise features
- Custom deployment consulting
- Performance optimization services

## License

This deployment configuration is provided under the same license as the FBMN-STATS application.

---

**Note**: This guide assumes Coolify v4.0 or later. Some features may vary depending on your Coolify version and configuration.